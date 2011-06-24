class Swf < ActiveRecord::Base
  
  has_attached_file :flash,
                    :url => "/flash/:class/:id-:basename/:basename.:extension",
                    :path => ":rails_root/public/flash/:class/:id-:basename/:basename.:extension"

  has_attached_file :image,
                    :url => "/image/:class/:id-:basename/:basename.:extension",
                    :path => ":rails_root/public/image/:class/:id-:basename/:basename.:extension"

  scope :un_download, where(:download => false)
  scope :has_image, where("image_url is not null")
end
