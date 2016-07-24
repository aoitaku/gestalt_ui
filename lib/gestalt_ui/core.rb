require 'gosu'
require 'forwardable'
require 'quincite'

module Gosu

  module Geometric

    class Rect

      attr_accessor :x, :y, :width, :height

      def initialize(x=0, y=0, width=0, height=0)
        @x = x
        @y = y
        @width = width
        @height = height
      end

      def ===(o)
        case o
        when Rect
          (mid_x - o.mid_x).abs <= (width + o.width) / 2 &&
          (mid_y - o.mid_y).abs <= (height + o.height) / 2
        else
        end
      end

      alias min_x x
      alias min_y y

      def mid_x
        x + width / 2
      end

      def max_x
        x + width
      end

      def mid_y
        y + height / 2
      end

      def max_y
        y + height
      end
    end

  end
end

module GestaltUI

  include Quincite

  @z_order = 0
  @default_font = nil
  @window_width = 0
  @window_height = 0

  def self.build(&proc)
    Quincite::UI.max_width = @window_width
    Quincite::UI.max_height = @window_height

    UI.build(UI::ContainerBox, &proc)
  end

  def self.equip(mod)
    Component.__send__(:include, const_get(mod))
  end

  def self.z_order
    @z_order
  end

  def self.z_order=(z)
    @z_order = z
  end

  def self.window_width
    @window_width
  end

  def self.window_width=(width)
    @window_width = width
  end

  def self.window_height
    @window_height
  end

  def self.window_height=(height)
    @window_height = height
  end

  def self.default_font
    @default_font
  end

  def self.default_font=(font)
    @default_font = font
  end

  def self.default_font_size
    @default_font.height
  end

  def self.default_font_size=(size)
    if @default_font
      @default_font = Gosu::Font.new(size, name: default_font.name)
    else
      @default_font = Gosu::Font.new(size)
    end
  end

  class Component < Gosu::Geometric::Rect

    include GestaltUI
    include UI::Component
    include UI::Control

    attr_accessor :window, :image

    def initialize(id='', *args)
      super(0, 0, 0, 0)
      init_component
      init_control
      self.id = id
    end

    def update
    end

    def update_collision
    end

    def draw
      if visible?
        draw_bg if bg_image
        draw_image(x, y) if image
        draw_border if border_width and border_color
      end
    end

    def draw_bg
      bg_image.draw(x, y, GestaltUI::z_order)
    end

    def draw_border
      draw_box(x, y, x + width, y + height, border_width, Gosu::Color.new(
        border_color.alpha,
        border_color.red,
        border_color.green,
        border_color.blue
      ))
    end

    def draw_image(x, y)
      image.draw(x, y)
    end

    def draw_line(x0, y0, x1, y1, width, color)
      x1 += width - 1
      y1 += width - 1
      if width == 1
        Gosu.draw_line(x0, y0, color, x1, y1, color, GestaltUI::z_order)
      else
        Gosu.draw_rect(x0, y0, x1 - x0, y1 - y1, color, GestaltUI::z_order)
      end
    end

    def draw_box(x0, y0, x1, y1, width, color)
      draw_line(x0, y0, x1 - width, y0, width, color)
      draw_line(x0, y0, x0, y1 - width, width, color)
      draw_line(x0, y1 - width, x1 - width, y1 - width, width, color)
      draw_line(x1 - width, y0, x1 - width, y1 - width, width, color)
    end

  end

  class Container < Component

    include UI::Container

    def initialize(*args)
      super
      init_container
    end

    def draw
      super
      components.each(&:draw) if visible?
    end

    def update
      super
      components.each(&:update)
    end

  end
end
