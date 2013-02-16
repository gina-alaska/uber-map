class AdminController < ApplicationController
  before_filter :require_admin_privs
  
  protected
  
  def require_admin_privs
    unless current_user.try(:admin?)
      flash[:error] = 'You do not have permission to view this page'
      redirect_to root_url
    end
  end
end
