require 'unicode/line_break'
require_relative 'text'

class Quincite::UI::TextLabel < GestaltUI::Component

  def self.unicode
    unless @unicode
      db = Unicode::DB.new
      @unicode = {
        line_break: Unicode::LineBreak.new(db),
        east_asian_width: Unicode::EastAsianWidth.new(db)
      }
    end
    @unicode
  end

  def line_break
    Quincite::UI::TextLabel.unicode[:line_break]
  end

  def east_asian_width
    Quincite::UI::TextLabel.unicode[:east_asian_width]
  end

  include Quincite::UI::Layouter

  attr_reader :components, :font, :text_align

  attr_accessor :color, :line_height

  def initialize(id='', text='', *argv)
    super(id)
    self.style_set :layout, :vertical_box
    self.text = text
    @line_height = 1.0
    self.style_set :align_items, :top
    self.style_set :justify_content, :left
    @font = GestaltUI::default_font
  end

  def font=(font)
    case font
    when Gosu::Font
      @font = font
    when String
      @font = Gosu::Font.new(GestaltUI::default_font_size, font)
    else
      @font = Gosu::Font.new(GestaltUI::default_font_size, font.to_s)
    end
  end

  def text=(text)
    @text = text.to_s
  end

  def text_align=(align)
    @justify_content = align
  end

  def draw
    return unless visible?
    super
    # 事前にパラメータを用意しておく
    param = draw_params
    components.each do |component|
      font.draw(component.text, component.x, component.y, GestaltUI::z_order, 1.0, 1.0, param[:color])
    end
  end

  def draw_params
    param = {}
    if color
      param[:color] = Gosu::Color.new(color.alpha, color.red, color.green, color.blue)
    else
      param[:color] = 0xff_ffffff
    end
    param
  end

  def flow_resize
    flow_segment
    super
  end

  def vertical_box_resize
    vertical_box_segment
    super
  end

  def horizontal_box_resize
    horizontal_box_segment
    super
  end

  # 行に分割するのは flow_resize 側に任せる.
  # flow_segment では禁則処理を行って分割可能位置で分割を行う.
  def flow_segment
    max_width = @width
    text_margin = [line_spacing, 0]
    @components = @text.each_line.flat_map {|line|
      line.split.flat_map {|chars|
        line_break.breakables(chars).map {|word|
          GestaltUI::Text.new.tap do |text_object|
            text_object.text = word
            text_object.style_set(:margin, text_margin)
          end
        }.to_a
      }.tap {|line| line.last.style_set(:break_after, true) }
    }
  end
  private :flow_segment

  def line_spacing
    case line_height
    when Float
      (font.height * line_height - font.height) / 2.0
    when Fixnum
      (line_height - font.height) / 2.0
    end
  end
  private :line_spacing

  # 現実装だと垂直レイアウトでは均等割はできない.
  # 均等割するときは入れ子にしないといけない.
  # 現在の Text クラスのような文字～語句単位のオブジェクトとは別に,
  # 複数の文字～語句をひとまとまりにした行単位のオブジェクトが必要かも.
  def vertical_box_segment
    text_margin = [line_spacing, 0]
    @components = @text.each_line.map do |line|
      GestaltUI::Text.new.tap do |text_object|
        text_object.text = line
        text_object.style_set(:margin, text_margin)
      end
    end
  end
  private :vertical_box_segment

  def horizontal_box_segment
    text_margin = [line_spacing, 0]
    @components = @text.each_char.slice_before {|char|
      curr, prev = char, curr
      /\s/ === char or (not narrow?(char) and not narrow?(prev))
    }.lazy.map(&:join).reject {|word| /\s/ === word }.map {|word|
      GestaltUI::Text.new.tap do |text_object|
        text_object.text = word
        text_object.style_set(:margin, text_margin)
      end
    }.to_a
  end
  private :horizontal_box_segment

  def narrow?(char)
    return false unless char
    case east_asian_width.east_asian_width(char.ord)
    when Unicode::EastAsianWidth::N, Unicode::EastAsianWidth::Na
      true
    else
      false
    end
  end
  private :narrow?

end
