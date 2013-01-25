class LayersController < ApplicationController
  def show
    @layer = Layer.where(slug: params[:id]).first
    respond_to do |format|
      format.json
    end
  end
  
  def template
    @layer = Layer.where(slug: params[:id]).first
    
    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::SanitizationFilter,
      ::LiquidFilter
      ], params[:attributes]
    
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
    end
  end
end
