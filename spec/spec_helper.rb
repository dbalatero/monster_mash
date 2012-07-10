$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'monster_mash'
require 'rspec'
require 'rspec/autorun'
require 'json'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.dirname(__FILE__) + "/fixtures/vcr_cassettes"
  c.hook_into :typhoeus
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end