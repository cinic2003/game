# encoding: utf-8
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

class Elss
  
  module URL2144
    URL = 'http://www.2144.cn'
    CATEGORY = 'http://www.2144.cn/html/'
    CATEGORY_NUM = 120..200
    DOWNLOAD = 'http://www.2144.cn/down.php?id='
  end
  
  def find_swf
    for i in URL2144::CATEGORY_NUM
      category_url = URL2144::CATEGORY + i.to_s
      puts category_url

      begin
        page = Nokogiri::HTML(open(category_url), nil, 'gb2312')
        links = page.css(".only_list li a")
        puts links.size
        links.each do |link|
          if link.attributes['href'].value.start_with?('/html')
            game_url = link.attributes['href'].value
            swf_id = game_url.split('/').last
            name = link.text
            
            download_url = URL2144::DOWNLOAD + swf_id
            begin
              page = Nokogiri::HTML(open(download_url), nil, 'gb2312')
              swf_url = page.css(".downlinks").empty? ? page.css(".downlinks")[0].attributes['href'].value : "#{URL2144::URL}#{game_url}"
            rescue OpenURI::HTTPError
              puts "Network error, next"
            end
          else
            puts "Not download link: #{link} "
          end
          
          puts name
          puts swf_url
          puts '------------------------------------'
        end        
      rescue OpenURI::HTTPError
        puts "Not find URL: #{category_url}"
      end
    end
  end
  
end

if __FILE__ == $0
  # require "#{File.dirname(__FILE__)}/../config/environment"
  Elss.new.find_swf
end
