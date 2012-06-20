class FirepointsController < ApplicationController
  def index
    @firepoints = Firepoint.detected(6.days.ago)
    
    geojson = { 
      type: "FeatureCollection", 
      features: @firepoints.collect do |f|
        {
          type: "Feature",
          geometry: RGeo::GeoJSON.encode(f.the_geom),
          properties: f.as_json
        }
      end
    }
    
    respond_to do |format|
      format.geojson { render json: geojson }
    end
  end
end
