class Rule
  include Mongoid::Document
  
  field :field,   type: String
  field :handler, type: String
  field :values,  type: Array
  
  embeds_one :style
  embedded_in :layer
  
  def as_json(*args)
    data = super
    data['style'] = style.as_json
    
    data
  end
end
