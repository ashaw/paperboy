$LOAD_PATH.unshift 'lib'

require 'rubygems'
require 'rake'
require 'rake/clean'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "paperboy"
    gem.summary = %Q{A tool to generate HTML summaries of popular stories}
    gem.description = %Q{HTML story list generator from the chartbeat API. Good for daily email newsletters.}
    gem.email = "almshaw@gmail.com"
    gem.homepage = "http://github.com/tpm/paperboy"
    gem.authors = ["Al Shaw"]
    gem.add_dependency 'chartbeat'
    gem.add_dependency 'stats_combiner', '>= 0.0.3'
    gem.add_dependency 'hashie'
    gem.add_dependency 'nokogiri'

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  #Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

# rocco for docs
begin
  require 'rocco/tasks'
  Rocco::make 'docs/'
rescue LoadError
  warn "#$! -- rocco tasks not loaded."
  task :rocco
end

desc 'Build rocco docs'
task :docs => :rocco
directory 'docs/'

desc 'Build docs and open in browser for the reading'
task :read => :docs do
  sh 'open docs/rocco.html'
end

# Make index.html a copy of rocco.html
file 'docs/index.html' => 'docs/paperboy.html' do |f|
  cp 'docs/paperboy.html', 'docs/index.html', :preserve => true
end
task :docs => 'docs/index.html'
CLEAN.include 'docs/index.html'

# Alias for docs task
task :doc => :docs

#gh-pages

desc "update gh-pages"
task :pages => [:docs] do
  file = "index.html"
  sh "git checkout gh-pages"
  sh "cp ./docs/#{file} #{file}"
  sh "git add #{file}"
  sh "git commit -m 'docs -> gh-pages'"
end