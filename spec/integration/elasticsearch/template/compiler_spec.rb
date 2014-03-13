require 'spec_helper'

describe Elasticsearch::Template::Compiler do
  let(:root){ examples_root }

  describe "#initialize" do
    it "creates object" do
      expect{ Elasticsearch::Template::Compiler.new('') }.to_not raise_error
    end
  end

  describe "#compile" do
    context "with missing template" do
      subject{ Elasticsearch::Template::Compiler.new(root) }

      it "raises an error" do
        expect{ subject.compile('unknown') }.to raise_error
      end
    end

    context "with existing template" do
      let(:template){ 'simple' }
      subject{ Elasticsearch::Template::Compiler.new(root) }

      it "does not raise an error" do
        expect{ subject.compile(template) }.to_not raise_error
      end
    end
  end

  describe "template simple" do
    let(:template){ 'simple' }
    subject{ Elasticsearch::Template::Compiler.new(root).read_mappings(template) }

    it { should be_a(Hash) }
    it { should have(1).items }

    it "contains a type named 'foo'" do
      subject['foo'].should be_true
    end

    context "type 'foo'" do
      it "contains a property 'title'" do
        foo = subject['foo']
        foo['properties']['title'].should_not be_nil
      end
    end
  end
end