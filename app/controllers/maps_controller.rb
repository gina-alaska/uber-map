class MapsController < ApplicationController
  layout 'admin'
  
  def index
  end
  
  def admin
    @map = active_map
    respond_to do |format|
      format.html { render :edit }
    end
  end
  
  def show
    respond_to do |format|
      format.html { render :layout => 'application' }
    end
  end
  
  def new
    @map = Map.new
    
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @map = Map.new(map_params)
    
    respond_to do |format|
      if @map.save
        format.html {
          flash['success'] = "Successfully created map #{@map.title}"
          redirect_to edit_map_path(@map)
        }
      else
        format.html {
          flash['error'] = 'An error was encountered while creating the map'
          render :new
        }
      end
    end
  end
  
  def edit
    @map = fetch_map
    
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @map = fetch_map
    
    respond_to do |format|
      if @map.update_attributes(map_params)
        format.html {
          flash[:success] = "Updated map #{@map.title}"
          redirect_to edit_map_path(@map)
        }
      else
        flash[:error] = 'Error while updating map'
        render 'edit'
      end
    end
  end
  
  protected
  
  def fetch_map
    Map.where(slug: params[:id]).first
  end
  
  def map_params
    map = params[:map].slice(:slug, :title, :description, :projection, :active)
  end
end
