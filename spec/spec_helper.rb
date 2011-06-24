$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'monster_mash'
require 'rspec'
require 'rspec/autorun'
require 'json'
require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = File.dirname(__FILE__) + "/fixtures/vcr_cassettes"
  c.stub_with :typhoeus
end

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end
