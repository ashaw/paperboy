require 'pp'
require 'open-uri'
require 'active_support'
require 'chartbeat'
require 'hashie'
require 'stats_combiner/filterer'
require 'nokogiri'

module Paperboy
  
  class Collector
    
    STORIES = []
    UNIQ_STORIES = []
    
    def initialize(opts = {})
      @opts = {
        :apikey => nil,
        :host => nil,
        :start_time => Date.yesterday.beginning_of_day.to_i,
        :end_time => Date.yesterday.end_of_day.to_i,
        :filters => nil,
        :img_xpath => nil,
        :blurb_xpath => nil
      }.merge!(opts)
      
      if @opts[:apikey].nil? || @opts[:host].nil?
        raise Paperboy::Error, "No Chartbeat API Key or Host Specified!"
      end
      
      # initialize a chartbeat object
      @c = Chartbeat.new :apikey => @opts[:apikey], :host => @opts[:host]
    end
    
    def run
      self.collect_stories
    end

 protected
 
    def get_collection_intervals  
      times = []
      i = @opts[:start_time]

      loop do        
        times << i
        i += 3600
        break if i >= @opts[:end_time] || @opts[:end_time] - @opts[:start_time] < 3600
      end
      times
    end
    
    def collect_stories
      times = self.get_collection_intervals
      
      times.each do |time|
        puts Time.at(time)
        h = Hashie::Mash.new(@c.snapshots(:timestamp => time))
        
        titles = h.titles.to_a
        paths = h.active
        
        if not titles.nil? || paths.nil?
          paths_visitors = paths.collect {|q| [q.path,q.total]} 
          
          # match titles to paths and add visitors
          titles.each do |title|
            paths_visitors.each do |path_visitor|
              if path_visitor[0] == title[0]
                title << path_visitor[1]
              end
            end
          end
        else
          warn "Warning! No data collected for #{Time.at(time)}. Results may be skewed! Try setting older timestamps for best results"
        end
        
        STORIES << titles
      end
      
      self.package_stories
    end

    
    def filter_story(hed,path)
      filters = @opts[:filters]
      d = StatsCombiner::Filterer.apply_filters! @opts[:filters], :title => hed, :path => path
      if not d[:prefix].nil?
          d[:prefix] = d[:prefix] + '.'
      end       
      d[:url] = "http://#{d[:prefix]}#{@opts[:host]}#{path}"
      d
    end
    
    def prepackage_stories
      STORIES.each do |hour|
        hour.each do |datum|
          path = datum[0].dup
          hed = datum[1].dup
          visitors = datum[2] || 0
          
          if @opts[:filters]
            d = self.filter_story(hed,path)
            hed = d[:title]
            path = d[:path]
            url = d[:url]
          else
            url = "http://#{@opts[:host]}#{path}"
          end
                    
          if not path.nil?
            if not UNIQ_STORIES.collect {|q| q[1] }.include?(hed)
              UNIQ_STORIES << [url,hed,visitors]
            else
              dupe_idx = UNIQ_STORIES.collect{|q| q[1]}.index(hed)
              UNIQ_STORIES[dupe_idx][2] += visitors
            end      
          end
        end
      end        
    end

    def package_stories
      
      self.prepackage_stories
      
      uniq_stories = UNIQ_STORIES.sort{|a,b| b[2] <=> a[2]}[0..9]
      
      story_pkgs = []
      
      #now that we have the top 10 stories of the day, let's get the images and descriptions
      uniq_stories.each do |story|
        story_pkg = []
        url = story[0]
        hed = story[1]
        visitors = story[2]
        
        begin
          d = Nokogiri::HTML(open(url))
          rescue OpenURI::HTTPError
            d = nil
        end
        
        if not d.nil?
          description = d.xpath(@opts[:blurb_xpath]).attr('content').value rescue nil
          img = d.xpath(@opts[:img_xpath]).attr('content').value rescue nil
        else
          description = img = ''
        end
        
        story_pkg = {
          :url => url,
          :hed => hed,
          :visitors => visitors,
          :blurb => description || '',
          :img => img || ''
        }
        story_pkgs << story_pkg
      end
      
      html = ''
      
      story_pkgs.each do |pkg|
      
        html << <<DOCUMENT
        <div class="story">
          <h2><a href="#{pkg[:url]}">#{pkg[:hed]}</a></h2>
DOCUMENT
        
        if not pkg[:img].empty?
          html << <<DOCUMENT
          <div class="img"><a href="#{pkg[:url]}"><img src="#{pkg[:img]}"></a></div>
DOCUMENT
        end
        
        if not pkg[:blurb].empty?
          html << <<DOCUMENT
          <div class="blurb">#{pkg[:blurb]}</div>
DOCUMENT
        end
        
        html << <<DOCUMENT
        </div>
DOCUMENT
      
      end
      
      f = File.new("#{@opts[:host]}_paperboy_output.html","w+")
      f.write(html)
      f.close
      
      pp story_pkgs
    end
  
  end
end

class Paperboy::Error < StandardError
end