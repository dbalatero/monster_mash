require 'typhoeus'

files = Dir.glob(File.dirname(__FILE__) + '/**/*.rb')
files.each { |f| require f }

module MonsterMash
end
