module LayersHelper
  def handler_text(handler)
    case handler
    when '>='
      ' greater than or equal to '
    when '>'
      ' greater than '
    when '<='
      ' less than or equal to '
    when '<'
      ' less than '
    when 'between'
      ' between '
    else
      handler.to_s.humanize
    end
  end
end
