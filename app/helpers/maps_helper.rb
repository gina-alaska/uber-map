module MapsHelper
  def add_layer_options(map, layers)
    items = layers.collect { |l| [l.name, add_map_layer_path(map, l)] }
    options_for_select(items)
  end
end
