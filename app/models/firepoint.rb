class Firepoint < ActiveRecord::Base
  set_primary_key 'gid'
  set_table_name 'firepoints'
  establish_connection :firepoints
  
  set_rgeo_factory_for_column(:the_geom,
      RGeo::Geographic.spherical_factory(:srid => 4326))

  default_scope order('time_tm DESC')

  class << self
    def detected(time_ago)
      where('time_tm > ?', time_ago)
    end
  end

  def latitude
    the_geom.lat
  end

  def longitude
    the_geom.lon
  end
  
  def hours_ago
    ((Time.now - time_tm) / 3600).round
  end

  def detection_age
    difference = Time.now - attributes['time_tm']

    if (difference <= 12.hours)
      '0_to_12hr'
    elsif (difference <= 24.hours)
      '12_to_24hr'
    elsif (difference <= 48.hours)
      '24_to_48hr'
    elsif (difference <= 6.days)
      'prev_6_days'
    else
      'really_old'
    end
  end
  
  def as_json
    {
      :id => self.gid,
      :temp => self.temp,
      :time => self.time_tm,
      :hours_ago => self.hours_ago
    }
  end

  def rank
    difference = Time.now - attributes['time_tm']

    if (difference <= 12.hours)
      4
    elsif (difference <= 24.hours)
      3
    elsif (difference <= 48.hours)
      2
    else
      1
    end
  end
end
