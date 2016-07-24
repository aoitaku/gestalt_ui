require 'gosu'
require_relative 'lib/gestalt_ui'

class GameWindow < Gosu::Window

  attr_accessor :ui, :mouse_event_dispatcher

  def initialize
    super 640, 480, false
    self.caption = "Göstalt UI"

    GestaltUI.window_width = self.width
    GestaltUI.window_height = self.height
    GestaltUI.default_font = Gosu::Font.new(self, Gosu::default_font_name, 22)
    GestaltUI.equip :MouseEventHandler

    ui = GestaltUI::build {
      layout :flow
      TextLabel {
        border width: 1, color: 0xffffff
        padding 8
        margin 4
        width :full
        text '相対的なサイズ指定'
      }
      ContainerBox {
        layout :flow
        margin 2
        top -2
        width :full
        ContainerBox {
          width 0.5
          ContainerBox {
            border width: 1, color: 0xffffff
            layout :vertical_box
            width :full
            padding 4
            margin 2
            TextButton {
              padding 4
              text '50% 幅の'
              width :full
            }
            TextButton {
              padding 4
              text "ボックスいっぱいに"
              width :full
            }
            TextButton {
              padding 4
              text 'テキストボタンの'
              width :full
            }
            TextButton {
              padding 4
              text '領域があります'
              width :full
            }
          }
        }
        ContainerBox {
          width 0.5
          ContainerBox {
            layout :vertical_box
            border width: 1, color: 0xffffff
            width :full
            padding 4
            margin 2
            TextButton {
              padding 4
              text '右側のボックスも'
              width :full
            }
            TextButton {
              padding 4
              text '50% の幅で'
              width :full
            }
            TextButton {
              padding 4
              text 'テキストボタンを'
              width :full
            }
            TextButton {
              padding 4
              text '垂直に並べています'
              width :full
              onclick -> * { Kernel.puts "hoge" }
            }
          }
        }
      }
    }
    ui.layout
    ui.window = self
    ui.all_components.each {|component| component.window = ui.window }
    @ui = ui
    @mouse_event_dispatcher = GestaltUI::MouseEventDispatcher.new(ui)
  end

  def update
    mouse_event_dispatcher.update
    mouse_event_dispatcher.dispatch
  end

  def draw
    ui.draw
  end

  def needs_cursor?
    true
  end

end

window = GameWindow.new
window.show
