require 'colorize'

class Game

end

class Board

end

class Peg
  def initialize(color: :black, empty: false, secret: false)
    @color = color

    if empty
      @peg = "  ".colorize(:background => :black) + " "
    elsif secret
      @peg = "??".white.on_black + " "
    else
      @peg = "XX".colorize(:color => @color).colorize(:background => @color) + " "
    end



  end

  def to_s
    return @peg
  end

end

blue= Peg.new(color: :blue)
secret = Peg.new(secret: true)
empty = Peg.new(empty: true)

puts "#{blue}#{empty}#{secret}"
