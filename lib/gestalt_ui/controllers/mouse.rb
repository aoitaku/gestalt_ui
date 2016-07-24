require 'weakref'

class GestaltUI::Mouse < Gosu::Geometric::Rect

  attr_reader :hover, :prev

  def initialize
    super(0, 0, 0, 0)
    @hover = nil
    @mouse_left = [false, false]
    @mouse_right = [false, false]
    @mouse_middle = [false, false]
  end

  def update(x, y)
    self.x = x
    self.y = y
    @mouse_left = [@mouse_left.last, Gosu.button_down?(Gosu::MsLeft)]
    @mouse_right = [@mouse_right.last, Gosu.button_down?(Gosu::MsRight)]
    @mouse_middle = [@mouse_middle.last, Gosu.button_down?(Gosu::MsMiddle)]
  end

  def hover=(component)
    @hover = component
  end

  def left_push?
    !@mouse_left.first && @mouse_left.last
  end

  def left_down?
    @mouse_left.first && @mouse_left.last
  end

  def left_release?
    @mouse_left.first && !@mouse_left.last
  end

  def right_push?
    !@mouse_right.first && @mouse_right.last
  end

  def right_down?
    @mouse_right.first && @mouse_right.last
  end

  def right_release?
    @mouse_right.first && !@mouse_right.last
  end

  def middle_push?
    !@mouse_middle.first && @mouse_middle.last
  end

  def middle_down?
    @mouse_middle.first && @mouse_middle.last
  end

  def middle_release?
    @mouse_middle && !@mouse_middle.last
  end

end

module GestaltUI

  class MouseEventDispatcher

    include GestaltUI
    include UI::EventDispatcher

    attr_reader :mouse, :mouse_prev

    def initialize(event_listener)
      super
      @mouse = Mouse.new
      @mouse_prev = Mouse.new
      @event = MouseEvent.new
    end

    def update
      mouse_prev.x = mouse.x
      mouse_prev.y = mouse.y
      mouse.update(event_listener.window.mouse_x, event_listener.window.mouse_y)
    end

    def mouse_move_from
      [mouse_prev.x, mouse_prev.y]
    end

    def mouse_move_to
      [mouse.x, mouse.y]
    end

    def mouse_move?
      mouse_move_from == mouse_move_to
    end

    def mouse_hover_change?
      not(mouse.left_down? or mouse.hover == mouse_prev.hover)
    end

    def dispatch
      target = event_listener.all(:desc).find {|target| target === mouse }
      unless mouse.left_down?
        mouse_prev.hover = mouse.hover
        mouse.hover = target and WeakRef.new(target)
      end
      event_listener.all(:desc).select {|target| target === mouse }.tap do |targets|
        if mouse.left_push?
          targets.any? do |current_target|
            event.fire(:mouse_left_push, target, current_target)
          end
        end
        if mouse.right_push?
          targets.any? do |current_target|
            event.fire(:mouse_right_push, target, current_target)
          end
        end
        if mouse.middle_push?
          targets.any? do |current_target|
            event.fire(:mouse_middle_push, current_target, target)
          end
        end
        if mouse.left_down?
          mouse.hover.activate if mouse.hover
          targets.any? do |current_target|
            event.fire(:mouse_left_down, current_target, target)
          end
        end
        if mouse.right_down?
          targets.any? do |current_target|
            event.fire(:mouse_right_down, current_target, target)
          end
        end
        if mouse.middle_down?
          targets.any? do |current_target|
            event.fire(:mouse_middle_down, current_target, target)
          end
        end
        if mouse.left_release?
          mouse_prev.hover.deactivate if mouse_prev.hover
          targets.any? do |current_target|
            event.fire(:mouse_left_release, current_target, target)
          end
        end
        if mouse.right_release?
          targets.any? do |current_target|
            event.fire(:mouse_right_release, current_target, target)
          end
        end
        if mouse.middle_release?
          targets.any? do |current_target|
            event.fire(:mouse_middle_release, current_target, target)
          end
        end
        if mouse_hover_change?
          event_listener.all(:desc).select {|target| target === mouse_prev.hover }.any? do |current_target|
            event.fire(:mouse_out, current_target, mouse_prev.hover, [mouse_prev.hover, mouse.hover])
          end
        end
        if mouse_move?
          targets.any? do |current_target|
            event.fire(:mouse_move, current_target, target, [mouse_move_from, mouse_move_to])
          end
        end
        if mouse_hover_change?
          targets.any? do |current_target|
            event.fire(:mouse_over, current_target, mouse.hover, [mouse_prev.hover, mouse.hover])
          end
        end
      end
    end

  end
end
