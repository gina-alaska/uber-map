Rails.application.config.middleware.use OmniAuth::Builder do
  require 'openid/store/filesystem' 
  provider :developer unless Rails.env.production?
  provider :openid, :store => OpenID::Store::Filesystem.new('/tmp')
end

