class MapsController < ApplicationController
  layout 'admin'
  
  def index
    @map = Map.where(slug: subdomain).first
  end
  
  def show
    @map = Map.where(slug: subdomain).first
    
    respond_to do |format|
      format.html { render :layout => 'application' }
    end
  end
  
  def new
    render :layout => false
  end
  
  protected
  
  def subdomain
    request.subdomains.first || 'fire'
  end
end
