class Poi < ActiveRecord::Base
  establish_connection :portal
  
  set_rgeo_factory_for_column(:geom,
      RGeo::Geographic.spherical_factory(:srid => 4326))

  def latitude
    geom.lat
  end

  def longitude
    geom.lon
  end
end
