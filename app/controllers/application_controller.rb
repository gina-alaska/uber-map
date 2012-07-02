class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_valid_site
  
  protected
  
  def check_valid_site
    if active_map.nil?
      flash[:error] = "Please create the first map"
      redirect_to new_map_path
    end
  end
  
  def subdomain
    request.subdomains.first || 'fire'
  end

  def active_map
    @active_map ||= Map.where(slug: subdomain).first
    @active_map = Map.first if @active_map.nil?
    
    @active_map
  end
  
  helper_method :subdomain, :active_map
end
