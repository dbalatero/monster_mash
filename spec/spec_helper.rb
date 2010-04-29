$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'monster_mash'
require 'spec'
require 'spec/autorun'
require 'typhoeus_spec_cache'
require 'json'

Spec::Runner.configure do |config|
  config.include(Typhoeus::SpecCacheMacros::InstanceMethods)
  config.extend(Typhoeus::SpecCacheMacros::ClassMethods)
end
