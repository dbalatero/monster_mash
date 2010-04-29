require File.dirname(__FILE__) + '/../spec_helper'

class MockApi < MonsterMash::Base
end

describe MonsterMash::Base do
  describe "inheriting defaults from superclasses" do
    class A < MonsterMash::Base
      defaults do
        cache_timeout 9999
      end
    end

    class B < A
    end

    class C < A
      defaults do
        cache_timeout 100
      end
    end

    it "should propagate defaults to B" do
      B.defaults.should == A.defaults
    end

    it "should allow override of defaults by C" do
      C.defaults.should_not == A.defaults
    end
  end

  describe "#self.defaults" do
    it "should default to nil" do
      MockApi.defaults.should == nil
    end

    it "should save a defaults proc in the class" do
      defaults_block = lambda { nil }
      MockApi.defaults(&defaults_block)

      MockApi.defaults.should == defaults_block
      MonsterMash::Base.defaults.should == nil
    end
  end

  describe "#get" do
    it "should proxy to build_method" do
      MockApi.should_receive(:build_method).
        with(:get, :method_name)
      MockApi.get(:method_name) { nil }
    end
  end

  describe "#post" do
    it "should proxy to build_method" do
      MockApi.should_receive(:build_method).
        with(:post, :method_name)
      MockApi.post(:method_name) { nil }
    end
  end

  describe "#put" do
    it "should proxy to build_method" do
      MockApi.should_receive(:build_method).
        with(:put, :method_name)
      MockApi.put(:method_name) { nil }
    end
  end

  describe "#delete" do
    it "should proxy to build_method" do
      MockApi.should_receive(:build_method).
        with(:delete, :method_name)
      MockApi.delete(:method_name) { nil }
    end
  end

  describe "#self.build_method" do
    before(:all) do
      @hydra = mock('hydra')
      unless MockApi.respond_to?(:my_method)
        MockApi.build_method(:get, :my_method) do
          uri 'http://google.com'
        end
      end
    end

    it "should create an instance (async parallel HTTP) method" do
      api = MockApi.new(@hydra)
      api.should respond_to(:my_method)
    end

    it "should create a class (sync serial HTTP) method" do
      MockApi.should respond_to(:my_method)
    end

    it "should raise an error if the name is in use" do
      lambda {
        MockApi.build_method(:get, :my_method) { nil }
      }.should raise_error(ArgumentError)
    end

    describe "checking validity" do
      it "should raise errors if the request is not valid" do
        api = MockApi.new(@hydra)
        lambda {
          api.my_method
        }.should raise_error(MonsterMash::InvalidRequest)
      end
    end

    describe "error propagation" do
      typhoeus_spec_cache("spec/cache/errors") do |hydra|
        before(:all) do
          class CustomMockError < StandardError; end

          MockApi.build_method(:get, :google_json2) do |search|
            uri 'http://ajax.googleapis.com/ajax/services/search/web'
            params({
              'v' => '1.0',
              'q' => search,
              'rsz' => 'large'
            })
            cache_timeout 999999
            handler do |response|
              raise CustomMockError, "my error"
            end
          end
        end

        it "should raise an error in a serial request" do
          lambda {
            MockApi.google_json2('david balatero')
          }.should raise_error(CustomMockError)
        end

        it "should propagate the error to the block in parallel request" do
          api = MockApi.new(hydra)
          propagated_error = nil
          api.google_json2('david balatero') do |urls, error|
            propagated_error = error
          end
          propagated_error.should be_an_instance_of(CustomMockError)
        end
      end
    end

    describe "a valid method" do
      typhoeus_spec_cache("spec/cache/google") do |hydra|
        before(:all) do
          MockApi.build_method(:get, :google_json) do |search|
            uri 'http://ajax.googleapis.com/ajax/services/search/web'
            params({
              'v' => '1.0',
              'q' => search,
              'rsz' => 'large'
            })
            cache_timeout 999999
            handler do |response|
              json = JSON.parse(response.body)
              json['responseData']['results'].map do |result|
                result['url']
              end
            end
          end
        end

        it "should do a serial query correctly" do
          saved_urls = MockApi.google_json('balatero')
          saved_urls.should have(8).things
        end

        it "should do a query correctly" do
          saved_urls = nil
          api = MockApi.new(hydra)
          api.google_json('balatero') do |urls, error|
            if !error
              saved_urls = urls
            end
          end
          hydra.run

          saved_urls.should have(8).things
        end
      end
    end
  end
end
