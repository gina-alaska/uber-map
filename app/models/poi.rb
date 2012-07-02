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
  
  def as_json
    {
      name: self.name,
      category: self.category,
      url: "<a href=\"#{self.url}\">#{self.url}</a>"
    }
  end
end
