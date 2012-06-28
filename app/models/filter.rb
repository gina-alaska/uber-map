class Filter
  include Mongoid::Document
  
  field :type,            type: String
  field :field,           type: String
  field :display_field,   type: String
  
  embedded_in :layer
end
