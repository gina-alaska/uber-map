class LayersController < ApplicationController
  layout 'admin'
  
  def index
    @layers = Layer.all
    
    respond_to do |format|
      format.html
    end
  end  
  
  def show
    @layer = Layer.where(slug: params[:id]).first
    respond_to do |format|
      format.json do
        render json: @layer.as_json
      end
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
        format.html { redirect_to admin_path }       
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
            redirect_to edit_layer_path(@layer)
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
      format.html { redirect_to admin_path }
    end
  end
  
  protected
  
  def layer_params
    layer = params[:layer].slice(:slug, :name, :data_type, :data_value, :projection)

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
