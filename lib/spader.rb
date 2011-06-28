# encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

class Spader
  attr_accessor :url, :page

  def initialize(url, encode)
    @url = url
    @page = Nokogiri::HTML(open(url), nil, encode)
  end

  def get_page_by_url(url)
    begin
      page = Nokogiri::HTML(open url)
    rescue Errno::ECONNREFUSED
      puts 'Connect Refused ---------------------'
    rescue OpenURI::HTTPError
      puts 'HTTP Error --------------------------'
    rescue EOFError
      puts 'EOF Error ---------------------------'
    end
    page
  end

  def get_swf_url_from_js(url, var, regexp)
    page = get_page_by_url(url)
    return nil if page.nil?

    js = page.search('script').detect {|js| js.to_s.include?(var)}
    unless js.to_s.scan(regexp).empty?
      swf_url = $1
    else
      puts "在 #{url} 中未找到swf"
    end
    swf_url
  end

end
