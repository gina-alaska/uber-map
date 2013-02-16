class User
  include Mongoid::Document
  
  field :provider, :type => String
  field :uid, :type => String
  field :name, :type => String
  field :email, :type => String
  field :admin, :type => Boolean, default: false
  
  attr_accessible :provider, :uid, :name, :email

  def self.find_with_omniauth(auth)
    self.where(:provider => auth['provider'], :uid => auth['uid']).first
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end
    end
  end  
end
