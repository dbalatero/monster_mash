require File.dirname(__FILE__) + '/../spec_helper'

describe MonsterMash::Request do
  describe "#new" do
    it "should evaluate the passed in block in context" do
      foo = nil
      bar = nil

      request = MonsterMash::Request.new(:get, "query") do |query|
        foo = self.class
        bar = query
      end
      foo.should == MonsterMash::Request
      bar.should == 'query'
    end

    it "should save the method" do
      request = MonsterMash::Request.new(:get)
      request.options[:method].should == :get
    end
  end

  describe "#handler" do
    before(:each) do
      @request = MonsterMash::Request.new(:get)
    end

    it "should set the handler" do
      block = lambda { nil }
      @request.handler(&block)
      @request.handler.should == block
    end
  end

  describe "#valid?" do
    before(:each) do
      @request = MonsterMash::Request.new(:get)
    end

    it "should be valid if there is a URI and a handler" do
      @request.uri "http://google.com"
      @request.handler { |response| puts response.body }
      @request.should be_valid
    end

    it "should not be valid if there is missing handler" do
      @request.uri "http://google.com"
      @request.should_not be_valid
    end

    it "should not be valid if there is a missing uri" do
      @request.handler { |response| puts response.body }
      @request.should_not be_valid
    end
  end

  describe "#uri" do
    before(:each) do
      @request = MonsterMash::Request.new(:get)
    end

    it "should set the uri, and return it" do
      @request.uri "http://google.com"
      @request.uri.should == "http://google.com"
    end
  end

  describe "method_missing methods" do
    before(:each) do
      @request = MonsterMash::Request.new(:get)
    end

    it "should set a correct value" do
      @request.timeout 100
      @request.options[:timeout].should == 100
    end

    it "should have a getter" do
      @request.timeout 100
      @request.timeout.should == 100
    end
  end
end
