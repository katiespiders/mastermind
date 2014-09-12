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
    play
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

    puts @secret_sequence
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
    won, lost = false, false

    while not (won || lost)

      print "Guess a sequence: "
      guess = gets.chomp
      guess = parse_guess(guess)
      while not guess
        guess = gets.chomp
        guess = parse_guess(guess)
      end
      hint = accuracy_check(guess)

      if guess == @secret_sequence
        won = true
        @board.update(guess, hint, @secret_sequence, @current_try)
        abort "You win...this time."
      elsif @current_try == @tries - 1
        lost = true
        @board.update(guess, hint, @secret_sequence, @current_try)
        abort "I win. Ha-ha. </Nelson Muntz>"
      else
        @board.update(guess, hint, @secret_sequence, @current_try)
        @current_try += 1
      end
    end
  end


  def parse_guess(guess)
    parsed_array = []
    if guess == ""
      print "You didn't enter a guess! Enter one! "
      return nil
    end
    if guess.include? " "
      guess_array = guess.split(" ")
    else
      guess_array = guess.split("")
    end

    if guess_array.length < @pegs
      print "You need to enter a #{@pegs}-color sequence. Try again. "
      return nil
    elsif guess_array.length > @pegs
      guess_array = guess_array[0...@pegs]
      puts "You entered too long of a sequence, so it was truncated to #{@pegs} colors. It's now #{guess_array.join(" ").upcase}."
    end

    guess_array.each do |color|

      case color.downcase
      when "red", "r"
        parsed_array << :light_red
      when "green", "g"
        parsed_array << :light_green
      when "yellow", "y"
        parsed_array << :light_yellow
      when "blue", "b"
        parsed_array << :light_blue
      when "magenta", "m"
        if @colors < 5
          print "There are no magenta pegs in this game. Enter a new guess. "
          return nil
        end
        parsed_array << :light_magenta
      when "cyan", "c"
        if @colors < 6
          print "There are no cyan pegs in this game. Enter a new guess. "
          return nil
        end
        parsed_array << :light_cyan
      else
        print "#{color} does not correspond to a valid peg color. Re-enter your guess. "
        return nil
      end
    end

    return parsed_array
  end


  def accuracy_check(guess)

    hint = []
    i = 0

    @secret_counts = Hash[@secret_sequence.collect { |color| [color, 0] }]

    (@secret_sequence.length).times do
      if @secret_sequence[i] == guess[i]
      #  @secret_counts[guess[i]] += 1
        hint << "[x]"
      elsif @secret_sequence.include? guess[i]
        if @secret_counts[guess[i]] == 0 then hint << "[o]" else hint << "[ ]" end
        @secret_counts[guess[i]] += 1
      else
        hint << "[ ]"
      end
      i += 1
    end

    return " -- " + hint.sort.reverse.join("")
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

      if @board[row].length > @pegs
        row_string += @board[row][col]
      end

      if row < 9
        row_label = " #{row+1} "
      else
        row_label = "#{row+1} "
      end

      if row == @tries
        row_label = "   "
      end

      board_string += (row_label + row_string + "\n")
      row += 1
    end
    board_string += "\n"
    return board_string
  end


  def update(guessed_sequence, hint, answer, current_try)
    won = guessed_sequence == answer
    lost = current_try == @tries - 1

    guessed_row = make_row(guessed_sequence)

    if not (won or lost)
      guessed_row << hint
    else
      @board[@tries] = make_row(answer)
    end

    @board[current_try] = guessed_row

    puts self
  end


  def make_row(sequence)
    pegs = []
    i=0
    sequence.each do |peg|
      pegs << Peg.new(color: sequence[i])
      i += 1
    end

    return pegs
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

g = Game.new(4,4,12)
g.play
