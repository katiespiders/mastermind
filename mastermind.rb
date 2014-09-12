require 'colorize'

class Game

  def initialize(colors=4, pegs=4, tries=8, duplicates=false)

    @colors = colors
    @current_try = 0
    @pegs = pegs
    @tries = tries
    @duplicates = duplicates
    @board = Board.new(@pegs, @tries)

    if colors > 6
      puts "You can't have #{colors} colors. You may have 6."
      colors = 6
    end

    all_peg_colors = [:light_red, :light_green, :light_blue, :light_yellow, :light_pink, :light_cyan]
    @peg_colors = all_peg_colors[0...@pegs]

    generate_secret_sequence

    puts @board
  end


  def generate_secret_sequence

    @secret_sequence = []
    if @duplicates
      @pegs.times { @secret_sequence << @peg_colors[rand(0...@colors)] }
    else
      @pegs.times do
        i = rand(0...@peg_colors.length)
        @secret_sequence << @peg_colors[i]
        @peg_colors.delete_at(i)
      end
    end

  end



  def play
  end


end

class Board

  def initialize(pegs, tries)
    @pegs = pegs
    @tries = tries
    @board = []

    @tries.times do
      temp_row = []
      @pegs.times { temp_row << Peg.new(empty: true) }
      @board << temp_row
    end

    secret_row = []
    @pegs.times { secret_row << Peg.new(secret: true) }
    @board << secret_row
  end


  def to_s
    row = 0
    board_string = "\n"
    (@tries+1).times do
      col = 0
      row_string = ""
      @pegs.times do
        row_string += @board[row][col].to_s
        col += 1
      end

      if row < 9
        row_label = " #{row+1} "
      else
        row_label = "#{row+1} "
      end

      if row == @tries
        # change row label to the appropriate number of spaces rather than a number for the secret sequence
      end
      board_string += (row_label + row_string + "\n")
      row += 1
    end
    board_string += "\n"
    return board_string
  end


  def update_board(guessed_sequence)
  end


  def reveal(secret_sequence)
  end


end

class Peg
  def initialize(color: :black, empty: false, secret: false)
    @color = color

    if empty
      @peg = "[] "
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

def peg_test
  blue = Peg.new(color: :blue)
  empty = Peg.new(empty: true)
  secret = Peg.new(secret: true)

  print blue, empty, secret
end

g=Game.new(5,6,10)
