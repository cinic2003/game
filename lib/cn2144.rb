# encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Cn2144

  module CN2144
    URL = 'http://www.2144.cn'
    CATEGORY = 'http://www.2144.cn/html/'
    DOWNLOAD = 'http://www.2144.cn/down.php?id='

    TOP_TAG = "div[@id='topnavs_fonts']//dd//a"
    RECOMMEND_CONT = "dl[@id='recommend_cont']//dd//a"

    CSS1 = ".games_lists a"
    CSS2 = ".typet_classimgs a"
    
  end

  def find_swf
    page = Nokogiri::HTML(open(CN2144::URL), nil, 'gb2312')
    links = page.css(CN2144::CSS1) + page.search(CN2144::RECOMMEND_CONT)
    tags = page.search(CN2144::TOP_TAG)

    links.each do |link|
      url = link.attributes['href'].value
      name = link.children.text
      image = link.children[0].attributes
      image_url = image.has_key?('src') ? image['src'].value : image['a'].value
      puts name 
      puts url
      puts image_url
      puts '---------------'
    end

    tags.each do |tag|
      name = tag.children[0].text
      url = tag.attributes['href'].value
      puts name
      puts url
      puts '================'
    end
  end

end

if __FILE__ == $0
  Cn2144.new.find_swf
end
