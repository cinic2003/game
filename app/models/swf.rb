class Swf < ActiveRecord::Base
  
  has_attached_file :flash,
                    :url => "/flash/:class/:attachment/:id/:basename/:style.:ectension",
                    :path => ":rails_root/publlic/flash/:class/:attachment/:id/:basename/:style.:ectension"

  has_attached_file :image,
                    :url => "/image/:class/:attachment/:id/:basename/:style.:ectension",
                    :path => ":rails_root/publlic/image/:class/:attachment/:id/:basename/:style.:ectension"

end
