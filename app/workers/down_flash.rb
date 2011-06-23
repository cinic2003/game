require 'rubygems'
require 'open-uri'

class DownFlash
  @queue = :download_swf

  def self.perform(swf_id)
    swf = Swf.find swf_id
    fin = open(swf.url).read
    File.open("#{Rails.root}/public/flash/#{swf.name}.swf", "w") do |fout|
      fout.write fin
      puts "Download the flash: #{swf.name} -- #{swf.url}"
      puts fout.inspect
      swf.flash = fout
      swf.save
    end

  end


end
