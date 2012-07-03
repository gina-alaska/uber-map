class FeedsController < ApplicationController
  VALID = %q{ firepoints poi }
  def show
    respond_to do |format|
      if VALID.include? params[:id]
        format.geojson { render json: self.send(params[:id].to_sym) }
      else
        format.html { render :file => Rails.root.join('public/404.html'), :status => :not_found }
        format.geojson { head :not_found }
      end
    end
  end
  
  protected 
  
  def firepoints
    @feed = Firepoint.detected(6.days.ago)
    
    { 
      type: "FeatureCollection", 
      features: @feed.collect do |f|
        {
          type: "Feature",
          geometry: RGeo::GeoJSON.encode(f.the_geom),
          properties: f.as_json
        }
      end
    }    
  end
  
  def poi
    @feed = Poi.active
    if params[:category]
      @feed = @feed.where(category: params[:category])
    end
    
    { 
      type: "FeatureCollection", 
      features: @feed.collect do |f|
        {
          type: "Feature",
          geometry: RGeo::GeoJSON.encode(f.geom),
          properties: f.as_json
        }
      end
    }
  end
end
