class Rule
  include Mongoid::Document
  
  field :field,   type: String
  field :handler, type: String
  field :values,  type: Array
  
  embeds_one :style
  embedded_in :layer
  
  def values
    read_attribute(:values).try(:join, ', ')
  end
  
  def values=(v)
    nv = v.gsub(/\s+/,'').split(',')
    logger.info '**************'
    logger.info nv
    write_attribute(:values, nv)
  end  
  
  def as_json(*args)
    data = super
    data['style'] = style.as_json
    
    data
  end
end
