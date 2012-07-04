class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_valid_site
  
  protected

  # Helper method to get the list of maps for the current site
  def site_maps
    if current_user && current_user.admin?
      Map.all
    else
      Map.active
    end
  end

  def current_user
    return nil if session[:user_id].nil?
    
    @current_user ||= User.find(session[:user_id])
  end
  
  def current_user=(user)
    @current_user = user
  end
  
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
  
  def auth_hash
    request.env['omniauth.auth']
  end
  
  helper_method :subdomain, :active_map, :current_user, :site_maps
end
