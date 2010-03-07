require 'rubygems'
require 'rake'
 
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "doco"
    gem.summary = %Q{Renders textile documents within mustache templates}
    gem.description = %Q{Renders textile documents within mustache templates}
    gem.email = "micheil@brandedcode.com"
    gem.homepage = "http://github.com/miksago/doco"
    gem.authors = ["Micheil Smith"]
    gem.add_dependency "rack"
    gem.add_dependency "mustache"
    gem.add_dependency "RedCloth"
    gem.require_path = 'lib'
    gem.files = %w(LICENSE README.textile Rakefile) + Dir.glob("{lib,bin}/**/{*,.[a-z]*}")
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end