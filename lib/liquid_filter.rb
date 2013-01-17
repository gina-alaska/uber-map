class LiquidFilter < HTML::Pipeline::Filter
  def call
    Liquid::Template.parse(@html).render(context[:data])
  end
end