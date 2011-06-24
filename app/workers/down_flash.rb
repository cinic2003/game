require 'rubygems'
require 'open-uri'

class DownFlash
  @queue = :download_swf

  def self.perform(swf_id)
    swf = Swf.find swf_id
    unless swf.download
      puts "Download the flash: #{swf.name} -- #{swf.url}"
      fin = open(swf.url).read
      File.open("#{Rails.root}/tmp/#{swf.name}.swf", "w+") do |fout|
        fout.write fin
        swf.flash = fout
        puts "#{swf.name} flash saved"
      end
      
      unless swf.image_url.blank?
        puts "Download the image: #{swf.name} -- #{swf.image_url}"
        img = open(swf.image_url).read
        File.open("#{Rails.root}/tmp/#{swf.name}.jpg", "w+") do |iout|
          iout.write img
          swf.image = iout
          puts "#{swf.name} image saved"
        end
      end
      swf.download = true
      swf.save
      File.delete("#{Rails.root}/tmp/#{swf.name}.jpg")
      File.delete("#{Rails.root}/tmp/#{swf.name}.swf")
      puts "---------------------------------------------"
    end
  end


end
