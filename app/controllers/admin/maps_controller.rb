class Admin::MapsController < AdminController
  before_filter :find_map, :except => [:index, :new, :create]
  
  def index
    redirect_to edit_admin_map_path(active_map)
  end
  
  def edit
    
  end
  
  def new
    @map = Map.new
  end
  
  def create
    @map = Map.new(params[:map].slice(:title, :slug, :projection, :active))
    
    respond_to do |format|
      if @map.save
        format.html {
          flash[:success] = "Created new map #{@map.title}"
          redirect_to edit_admin_map_url(@map, host: @map.url)
        }
      else
        format.html {
          render :new
        }
      end
    end
  end
  
  def destroy
    respond_to do |format|
      if @map.destroy
        format.html {
          flash[:success] = "Deleted map #{@map.title}"
          @next = Map.active.first
          redirect_to edit_admin_map_url(@next, host: @next.url)
        }
      else
        format.html {
          flash[:error] = "There was an error while trying to delete the map"
          redirect_to edit_admin_map_path(@map)
        }
      end
    end
  end
  
  protected
  
  def find_map
    @map = Map.where(slug: params[:id]).first
  end
end
