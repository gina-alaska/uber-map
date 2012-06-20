class MapsController < ApplicationController
  layout 'admin'
  
  def index
  end
  
  def show
    respond_to do |format|
      format.html { render :layout => 'application' }
    end
  end
  
  def new
    render :layout => false
  end
end
