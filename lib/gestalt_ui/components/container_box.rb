class Quincite::UI::ContainerBox < GestaltUI::Container

  include Quincite::UI::Layouter

  def initialize(*args)
    super
    self.style_set :justify_content, :left
    self.style_set :align_items, :top
    self.style_set :layout, :vertical_box
  end

end
