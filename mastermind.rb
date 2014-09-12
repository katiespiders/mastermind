require 'colorize'

class Game
  attr_accessor :secret_sequence, :current_try

  def initialize(colors=4, pegs=4, tries=8, duplicates=true)

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

    if pegs > colors and not duplicates
      puts "If you want more pegs than colors, you have to allow duplicates."
      @duplicates = true
    end

    all_peg_colors = [:light_red, :light_green, :light_blue, :light_yellow, :light_magenta, :light_cyan]
    @peg_colors = all_peg_colors[0...@pegs]

    generate_secret_sequence
    show_instructions
  end


  def generate_secret_sequence

    @secret_sequence = []
    if @duplicates
      @pegs.times { @secret_sequence << @peg_colors[rand(0...@peg_colors.length)] }
    else
      color_list = @peg_colors.collect { |color| color}

      @pegs.times do
        i = rand(0...color_list.length)
        @secret_sequence << color_list[i]
        color_list.delete_at(i)
      end
    end
  end


  def show_instructions
    color_codes = {
      :light_red => ("(R)ed").colorize(:black),
      :light_green => ("(G)reen").colorize(:black),
      :light_yellow => ("(Y)ellow").colorize(:black),
      :light_blue => ("(B)lue").colorize(:black),
      :light_magenta => ("(M)agenta").colorize(:black),
      :light_cyan => ("(C)yan").colorize(:black)
    }

    color_strings = []
    @peg_colors.each { |peg| color_strings << color_codes[peg] }

    puts "\nYou are trying to guess a sequence of #{@pegs} colors. After each guess, you will see how close you are. Each [x] represents one peg that is the correct color in the correct place; each [o] represents a peg that is the correct color but not in the correct place; and each [ ] represents a peg that is an incorrect color. You have #{@tries} tries.\n"
    puts @board
    puts "Enter a sequence of #{@pegs} colors. Possible colors are #{list_to_text(color_strings)}. There #{if @duplicates then "may be" else "will not be" end} multiple pegs of the same color."


  end


  def list_to_text(list, separator=" and ")
    if list.length > 2
      i = 0
      text = ""

      (list.length - 1).times do
        text += list[i] + ", "
        i += 1
      end

      text += (separator.lstrip + list.last)
      return text

    elsif list.length == 2
      return list.join(separator)

    else
      return list[0]
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
        row_label = " " * @tries.to_s.length + "  "
      end

      board_string += (row_label + row_string + "\n")
      row += 1
    end
    board_string += "\n"
    return board_string
  end


  def update_board(guessed_sequence, current_try)
    current_row = @board[current_try]
    guessed_row = []

    i=0
    current_row.each do |peg|
      guessed_row << Peg.new(color: guessed_sequence[i])
      i += 1
    end

    @board[current_try] = guessed_row
    puts self
  end

end

class Peg
  def initialize(color: :black, empty: false, secret: false)
    @color = color

    if empty
      @peg = "[ ] "
    elsif secret
      @peg = "[?]".white.on_black + " "
    else
      @peg = "[X]".colorize(:color => @color) + " "
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

g = Game.new
g.play
