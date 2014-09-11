require 'colorize'

class Game

end

class Board

end

class Peg
  attr_accessor :color

  def initialize(color: :black, secret: false, empty: false)
    @peg = " __\n|XX|\n|XX|\n"
    if empty then @peg.gsub!("X", " ") end
    if secret then @peg.gsub!("X", "?") end
    @peg[10,2] = @peg[10,2].underline
    @color = color
  end

  def to_s
    return @peg.colorize(@color)
  end

end
