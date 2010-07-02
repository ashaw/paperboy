require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "paperboy"
    gem.summary = %Q{A tool to generate HTML summaries of popular stories}
    gem.description = %Q{HTML story list generator from the chartbeat API. Good for daily email newsletters.}
    gem.email = "almshaw@gmail.com"
    gem.homepage = "http://github.com/tpm/paperboy"
    gem.authors = ["Al Shaw"]
    gem.add_dependency 'activesupport'
    gem.add_dependency 'chartbeat'
    gem.add_dependency 'stats_combiner', '>= 0.0.3'
    gem.add_dependency 'hashie'
    gem.add_dependency 'nokogiri'

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end