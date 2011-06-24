require File.dirname(__FILE__) + '/../spec_helper'

class ApplyDefaultsA < MonsterMash::Base
  defaults do
    timeout 100
    cache_timeout 9999
  end
end

class ApplyDefaultsB < ApplyDefaultsA
  defaults do
    timeout 50
  end
end


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

  describe "adding to default params" do
    before(:each) do
      @request = MonsterMash::Request.new(:get) do
        params :api_key => 'fdsa',
               :format => 'json'
      end
    end

    it "should merge in the params hash" do
      @request.execute_dsl do
        params :format => 'xml',
               :a => 'ok',
               :b => 'ok2'
      end

      @request.options[:params].should == {
        :api_key => 'fdsa',
        :format => 'xml',
        :a => 'ok',
        :b => 'ok2'
      }
    end
  end

  describe "#apply_defaults" do
    it "should apply the defaults in inheritance order" do
      request = MonsterMash::Request.new(:get)
      request.apply_defaults(ApplyDefaultsB.defaults)

      request.options[:timeout].should == 50
      request.options[:cache_timeout].should == 9999
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
      @request.errors.should have(1).thing
    end

    it "should not be valid if there is a missing uri" do
      @request.handler { |response| puts response.body }
      @request.should_not be_valid
      @request.errors.should have(1).thing
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

    context "when a base uri is set" do
      before do
        @request.base_uri "http://google.com"
      end

      it "joins the two uris" do
        @request.uri "/test"
        @request.uri.should eq "http://google.com/test"
      end

      it "can be overridden" do
        @request.uri "http://test.local"
        @request.uri.should eq "http://test.local"
      end

      context "but no uri is specified" do
        it "defaults to the base uri" do
          @request.uri.should eq "http://google.com"
        end
      end
    end
  end

  describe "#base_uri" do
    before(:each) do
      @request = MonsterMash::Request.new(:get)
    end

    it "should set the base uri, and return it" do
      @request.base_uri "http://google.com"
      @request.base_uri.should eq "http://google.com"
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
