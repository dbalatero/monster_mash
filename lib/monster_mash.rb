require 'typhoeus'

require File.dirname(__FILE__) + '/monster_mash/inheritable_attributes'
files = Dir.glob(File.dirname(__FILE__) + '/**/*.rb')
files.each { |f| require f }

module MonsterMash
end
