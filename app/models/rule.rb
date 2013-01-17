class Rule
  include Mongoid::Document
  
  field :field,           type: String
  field :handler,         type: String
  field :values,          type: Array
  field :legendLabel,     type: String
  
  embeds_one :style
  embedded_in :layer
  
  def values
    read_attribute(:values).try(:join, ', ')
  end
  
  def values=(v)
    v = v.gsub(/\s+/,'') if handler == 'BETWEEN'
    v = v.split(',')
    logger.info '**************'
    logger.info v
    write_attribute(:values, v)
  end  
  
  def as_json(*args)
    data = super
    data['style'] = style.as_json
    
    data
  end
end
