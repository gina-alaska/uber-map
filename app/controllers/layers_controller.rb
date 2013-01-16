class LayersController < ApplicationController
  def show
    @layer = Layer.where(slug: params[:id]).first
    respond_to do |format|
      format.json do
        render json: @layer
      end
    end
  end
end
