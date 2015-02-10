require 'spec_helper'

describe Figure do

  describe "method missing" do
    it "should otherwise respond to method_missing the usual way" do
      expect{ described_class.plip }.to raise_error(NoMethodError)
    end
  end

  describe "find config" do
    it "should not parse a random file in config directory" do
      expect{ described_class.other_config }.to raise_error(NoMethodError)
    end

    it "should find files to parse and get config from them" do
      expect(described_class.plop.default.plop).to eq('plop')
    end

    context "gaston" do
      before {
        Figure.env = 'production'
      }

      it "should find Gaston files to parse and get config from them" do
        expect(described_class.gaston.is_parsed).to eq('production')
        expect(described_class.gaston.production.inherits_gaston_default).to eq(true)
        expect(described_class.gerard.production.gerard.is_found_here_too).to eq(true)
      end
    end
  end

  describe 'defaults' do
    it "should have the correct values for foo" do
      expect(described_class.plop.foo.plop).to eq('plawp')
      expect(described_class.plop.foo.plip).to eq('pleep')
    end

    it "should have the correct values for bar" do
      expect(described_class.plop.bar.plop).to eq('plowp')
      expect(described_class.plop.bar.plip).to eq(described_class.plop.default.plip)
    end

    it "should have the correct values for baz" do
      expect(described_class.plop.baz.plop).to eq(described_class.plop.default.plop)
      expect(described_class.plop.baz.plip).to eq(described_class.plop.default.plip)
    end

    it "should find defaults for much more nested values" do
      expect(described_class.plop.default.more.nested.inherited.value).to eq('inherited')
      expect(described_class.plop.much.more.nested.defined.value).to eq('value')
      expect(described_class.plop.much.more.nested.inherited.value).to eq(described_class.plop.default.more.nested.inherited.value)
    end
  end

  describe 'populate' do
    it "should be possible to alter configuration on the fly" do
      described_class.plop.much.more.nested.defined[:value] = "own_value"

      expect(described_class.plop.much.more.nested.defined.value).to eq('own_value')
    end

    it "should be possible to add nested configuration on the fly" do
      described_class.plop.much.more.nested.defined[:other_value] = "other_value"

      expect(described_class.plop.much.more.nested.defined.other_value).to eq('other_value')
    end

    after {
      described_class.plop.much.more.nested.defined[:value] = "value"
    }
  end

  describe 'forward' do
    describe 'default bim' do
      { bom: 'bim', plap: 'default_bim' }.each do |k, v|
        context "#{k} bim" do
          let(:klass) { described_class.clone }

          before {
            bim = Class.new { |c| c.send :define_method, :bim, ->{k} }
            Figure.responders << bim.new
          }

          it "find the correct values taking plip value into account" do
            expect(klass.plop.yet_another.context.name).to eq(v)
          end

          after { Figure.responders.clear }
        end
      end
    end

    describe 'default blip' do
      { blop: 'blip', bim: 'default_name' }.each do |k, v|
        context "#{k} blip" do
          let(:klass) { described_class.clone }

          before {
            Figure::Figurine.send :define_singleton_method, :blip, -> {k}
          }

          it "find the correct values taking blip value into account" do
            expect(klass.plop.other.context.name).to eq(v)
          end
        end
      end
    end

    describe 'env' do
      { test: { val: 'test', nested_val: 'nested_test' },
        development: { val: 'default', nested_val: 'default_nested_val' },
        production: { val: 'default', nested_val: 'nested_production' } }.each do |env, values|

        let(:klass) { described_class.clone }

        it "should be able to forward the call to a child" do
          expect(klass.instance[:environments].can_forward?).to eq(true)
        end

        context "#{env} environment" do
          before {
            described_class.configure do |config|
              config.env = env
            end
          }

          it "should return the right value environment aware" do
            expect(klass.environments.this.env.val).to eq(values[:val])
            expect(klass.environments.that.nested_env.nested_val).to eq(values[:nested_val])
            expect(klass.environments.that.nested_env.other_nested_val).to eq('other_default_nested_val')
          end

          after {
            described_class.configure do |config|
              config.env = nil
            end
          }
        end
      end
    end
  end

  describe 'gaston' do
    let(:klass) { Gaston.clone }

    it "provides a Gaston class" do
      expect(defined? Gaston).to eq('constant')
    end

    context "default env" do
      before {
        Figure.configure do |fig|
          fig.env = :development
        end
      }

      it "provides configuration as Gaston did" do
        expect(klass.is_parsed).to eq(true)
        expect(klass.inherits_gaston_default).to eq(true)
        expect(klass.nested.thing).to eq('thing')
        expect(klass.nested.stuff).to eq('stuff')
      end
    end

    context "production provided by Figure" do
      before {
        Figure.configure do |fig|
          fig.env = :production
        end
      }

      it "provides configuration as Gaston did" do
        expect(klass.is_parsed).to eq('production')
        expect(klass.inherits_gaston_default).to eq(true)
        expect(klass.nested.thing).to eq('production')
        expect(klass.nested.stuff).to eq('stuff')
      end
    end

    context "production provided by Rails" do
      before {
        class Rails
          class << self
            attr_accessor :env
            def root; Pathname.new 'spec'; end
          end
        end

        Rails.env = 'production'

        FileUtils.symlink 'fixtures', 'spec/config'
        Figure::RailsInitializer.initialize!
      }

      it "provides configuration as Gaston did" do
        expect(klass.is_parsed).to eq('production')
        expect(klass.inherits_gaston_default).to eq(true)
        expect(klass.nested.thing).to eq('production')
        expect(klass.nested.stuff).to eq('stuff')
      end
    end

    after {
      Figure.configure do |fig|
        fig.env = nil
      end

      FileUtils.rm_f 'spec/config'
      Figure.responders.delete Rails if defined? Rails
    }
  end

  describe "Rails" do
    before {
      class Rails
        class << self
          attr_accessor :env
          def root; Pathname.new 'spec'; end
        end
      end

      Rails.env = 'production'

      FileUtils.symlink 'fixtures', 'spec/config'
      Figure::RailsInitializer.initialize!
    }

    let(:figure) { Figure.clone }
    let(:gaston) { Gaston.clone }

    it "retrieves values according to Rails.env" do
      expect(figure.environments.this.env.val).to eq('default')
      expect(figure.environments.that.nested_env.nested_val).to eq('nested_production')
      expect(gaston.is_parsed).to eq('production')
      expect(gaston.inherits_gaston_default).to eq(true)
      expect(gaston.nested.thing).to eq('production')
      expect(gaston.nested.stuff).to eq('stuff')
      expect(gaston.gerard.is_found_here_too).to eq(true)
      expect(gaston.gerard.is_gaston_s).to eq('brother')
      expect(gaston.gerard.nests.in).to eq("gerard's place")
      expect(figure.plop.foo.plop).to eq('plawp')
      expect(figure.plop.foo.plip).to eq('pleep')
      expect(figure.plop.bar.plop).to eq('plowp')
      expect(figure.plop.bar.plip).to eq(figure.plop.default.plip)
      expect(figure.plop.baz.plop).to eq(figure.plop.default.plop)
      expect(figure.plop.baz.plip).to eq(figure.plop.default.plip)
      expect(figure.plop.default.more.nested.inherited.value).to eq('inherited')
      expect(figure.plop.much.more.nested.defined.value).to eq('value')
      expect(figure.plop.much.more.nested.inherited.value).to eq(figure.plop.default.more.nested.inherited.value)
    end

    after {
      Figure.responders.delete Rails if defined? ::Rails
      Object.send :remove_const, :Rails if defined? ::Rails

      FileUtils.rm_f 'spec/config'
      FileUtils.rm_f 'spec/fixtures/fixtures'
    }
  end
end
