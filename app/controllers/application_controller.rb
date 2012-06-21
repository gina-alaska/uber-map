class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  protected
  
  def subdomain
    request.subdomains.first || 'fire'
  end

  def active_map
    @active_map ||= Map.where(slug: subdomain).first
    @active_map = Map.first if map.nil?
    
    @active_map
  end
  
  helper_method :subdomain, :active_map
end
