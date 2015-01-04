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

    it "should find Gaston files to parse and get config from them" do
      expect(described_class.gaston.default.is_parsed).to eq(true)
      expect(described_class.gaston.namespace.is_parsed).to eq('namespace')
      expect(described_class.gaston.namespace.inherits_gaston_default).to eq(true)
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

  describe 'figure_out' do
    {test: 'test', development: 'default', production: 'default'}.each do |env, val|
      let(:klass) { described_class.clone }

      context "#{env} environment" do
        before {
          klass.configure do |config|
            config.env = env
          end
        }

        it "should return the right value environment aware" do
          expect(klass.environments.this.env.val).to eq(val)
        end

        after {
          klass.configure do |config|
            config.env = nil
          end
        }
      end
    end
  end
end
