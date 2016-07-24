class GestaltUI::Text < GestaltUI::Component

  attr_reader :text

  def initialize(id='', text='', *argv)
    super(id)
    self.text = text
  end

  def text=(text)
    @text = text.to_s
  end

  def resize(parent)
    super
    @content_width = parent.font.text_width(text)
    @content_height = parent.font.height
    update_collision
    self
  end

end
