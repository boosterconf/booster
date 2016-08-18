class Bio < ActiveRecord::Base
  belongs_to :user
  attr_accessible :picture, :title, :twitter_handle, :blog, :bio
  has_attached_file :picture, PAPERCLIP_CONFIG.merge({
              styles: {
                  quad: {
                    geometry: '400x400',
                    convert_options: '-colorspace Gray -colorspace sRGB',
                    s3_headers: {
                        'Cache-Control' => 'max-age=2592000',
                        'Expires' => 30.days.from_now.httpdate
                    }
                  }
              },
              default_style: :quad
          })
  validates_attachment_content_type :picture,
                                    :content_type =>
                                        ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png'],
                                    :message => " only image files are allowed "
  validates_attachment_size :picture, :less_than => 3.megabyte,
                            :message => " max size is 3 M"

  def good_enough?
    picture && bio
  end
end
