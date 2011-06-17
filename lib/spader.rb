# encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

class Spader
  attr_accessor :url, :page
  
  def initialize(url)
    @url = url
    @page = Nokogiri::HTML(open url)
  end

  def get_page_by_url(url)
    page = Nokogiri::HTML(open url)
  end

end
