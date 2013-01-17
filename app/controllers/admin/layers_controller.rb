class Admin::LayersController < AdminController
  def index
    @layers = Layer.all
    
    respond_to do |format|
      format.html
    end
  end
  
  def legend
    @layer = Layer.where(slug: params[:id]).first
    
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  def new
    @layer = Layer.new
    
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @layer = Layer.new(layer_params)
    
    respond_to do |format|
      if @layer.save
        flash[:success] = "Successfully created layer #{@layer.name}"
        format.html { redirect_to admin_maps_path }       
      else
        flash[:error] = "Error while creating layer"
        format.html { render 'new' }
      end
    end    
  end
  
  def edit
    @layer = Layer.where(slug: params[:id]).first
    
    respond_to do |format|
      format.html 
    end
  end  
  
  def update
    @layer = Layer.where(slug: params[:id]).first
    
    respond_to do |format|
      if @layer.update_attributes(layer_params)
        flash[:success] = "Successfully updated layer #{@layer.name}"
        format.html { 
          if request.xhr?
            render 'edit', :layout => false 
          else
            redirect_to edit_admin_layer_path(@layer)
          end
        }       
      else
        flash[:error] = "Error while updating layer"
        format.html { render 'edit' }
      end
    end
  end
  
  def destroy
    @layer = Layer.where(slug: params[:id]).first
    
    respond_to do |format|
      if @layer.destroy
        flash[:success] = "Successfully deleted layer"
      else
        flash[:error] = "Error while deleting layer"
      end
      format.html { redirect_to admin_maps_path }
    end
  end
  
  def remove
    @map = Map.where(slug: params[:map_id]).first
    @layer = Layer.where(slug: params[:id]).first

    # don't know why but this fixes an issue with deleting from HABTM in mongoid
    @map.layers.inspect
    @map.layers.delete(@layer)
    
    respond_to do |format|
      if @map.save
        format.html {
          if request.xhr?
            render :partial => '/admin/maps/layers', locals: { map: @map }
          else
            flash[:success] = "Removed #{@layer.name} from #{@map.title}"
            redirect_to edit_admin_map_path(@map)
          end
        }
      else
        flash[:error] = 'Error while trying to remove layer from the map'
        format.html {
          if request.xhr?
            render :partial => '/admin/maps/layers', locals: { map: @map }
          else
            redirect_to edit_admin_map_path(@map)
          end          
        }
      end
    end
    
  end
  
  def add
    @map = Map.where(slug: params[:map_id]).first
    @layer = Layer.where(slug: params[:id]).first
    
    @map.layers << @layer
    respond_to do |format|
      if @map.save
        format.html {
          if request.xhr?
            render :partial => '/admin/maps/layers', locals: { map: @map }
          else
            flash['success'] = "Added #{@layer.name} to #{@map.title}"
            redirect_to edit_admin_map_path(@map)
          end
        }
      else
        flash['error'] = 'Error while trying to add layer to the map'
        format.html {
          if request.xhr?
            render :partial => '/admin/maps/layers', locals: { map: @map }
          else
            redirect_to edit_admin_map_path(@map)
          end          
        }
      end
    end
  end
  
  protected
  
  def layer_params
    layer = params[:layer].slice(:slug, :name, :select_by_default, :popup_template, :data_type, :data_value, :projection, :filter, :attribution)

    if params[:layer].include?(:upload)
      upload_io = params[:layer][:upload]    
      layer['data_type'] = upload_io.original_filename.split('.').last
      layer['data_value'] = upload_io.read
    end
    
    if params[:layer][:style]
      layer['style'] = params[:layer][:style]
    end
    
    rules = params[:layer][:rules].values
    rules.reject! { |r| logger.info r.inspect; r[:field].empty? || r[:handler].empty? }
    layer['rules'] = rules
    
    layer
  end
end
