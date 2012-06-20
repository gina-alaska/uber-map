class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  protected
  
  def subdomain
    request.subdomains.first || 'fire'
  end

  def active_map
    map = Map.where(slug: subdomain).first
  end
  
  helper_method :subdomain, :active_map
end
