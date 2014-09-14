require 'colorize'

class Game
  def initialize(colors=6, pegs=4, tries=8, duplicates=true)

    @colors = colors
    @current_try = 0
    @pegs = pegs
    @tries = tries
    @duplicates = duplicates
    @board = Board.new(@pegs, @tries)

    all_peg_colors = [:light_red, :light_green, :light_blue, :light_yellow, :light_magenta, :light_cyan]
    available_colors = all_peg_colors.length


    if @colors > available_colors
      puts "You can't have #{@colors} colors. You may have #{available_colors}."
      @colors = available_colors
    end
    @peg_colors = all_peg_colors.sample(@colors)

    if pegs > colors && (not duplicates)
      puts "If you want more pegs than colors, you have to allow duplicates."
      @duplicates = true
    end

    generate_secret_sequence
    show_instructions
    play
  end


  def generate_secret_sequence

    @secret_sequence = []
    if @duplicates
      @pegs.times { @secret_sequence << @peg_colors[rand(0...@colors)] }
    else
      @secret_sequence = @peg_colors.sample(@pegs)
    end

    puts @secret_sequence.join(" ").gsub("light_", "")
  end


  def show_instructions
    color_codes = {
      :light_red => ("(R)ed"),
      :light_green => ("(G)reen"),
      :light_yellow => ("(Y)ellow"),
      :light_blue => ("(B)lue"),
      :light_magenta => ("(M)agenta"),
      :light_cyan => ("(C)yan")
    }

    color_strings = @peg_colors.collect { |color| color_codes[color] }

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
    over = false

    while not over
      puts "round #{@current_try}, over=#{over}"
      print "Guess a sequence: "
      guess = gets.chomp
      guess = parse_guess(guess)
      while not guess
        guess = gets.chomp
        guess = parse_guess(guess)
      end
      hint = accuracy_check(guess)
      @board.update(guess, hint, @secret_sequence, @current_try)


      if guess == @secret_sequence
        puts "You win...this time."
        over = true
      elsif @current_try == @tries - 1
        puts "You lose. Ha-ha. </Nelson Muntz>"
        over = true
      end
      @current_try += 1
      puts "on to round #{@current_try}, over=#{over}"
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
        color_symbol = :light_red
      when "green", "g"
        color_symbol = :light_green
      when "yellow", "y"
        color_symbol = :light_yellow
      when "blue", "b"
        color_symbol = :light_blue
      when "magenta", "m"
        color_symbol = :light_magenta
      when "cyan", "c"
        color_symbol = :light_cyan
      else
        print "#{color} does not correspond to a valid peg color. Re-enter your guess. "
        return nil
      end

      if not @peg_colors.include? color_symbol
        print "#{color_symbol.to_s.sub("light_","").capitalize} is not a valid peg color in this game. Enter a new guess. "
        return nil
      end
      parsed_array << color_symbol
    end
    return parsed_array
  end


  def accuracy_check(guess)

    guess_array = guess.clone       # why did I have to do this to keep the original arrays (passed as arguments) from being permanently modified?
    answer = @secret_sequence.clone
    hint = []

    i = 0
    (guess_array.length).times do
      if guess_array[i] == answer[i]
        hint << "[x]"
        answer[i], guess_array[i] = :guess_array_match, :answer_match
      end
      i+=1
    end

    i=0
    (guess_array.length).times do
      if answer.include? guess_array[i]
        hint << "[o]"
         j = answer.index(guess_array[i])
         answer[j] = :color_match
      end
      i+=1
    end

    (guess_array.length - hint.length).times { hint << "[ ]"}

    return " -- " + hint.join("")
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
    won = (guessed_sequence == answer)
    lost = (current_try == @tries - 1)

    guessed_row = make_row(guessed_sequence)

    if not (won || lost)
      guessed_row << hint
    else
      @board[@tries] = make_row(answer)
    end

    @board[current_try] = guessed_row

    puts self
  end


  def make_row(sequence)
    return sequence.collect { |color| Peg.new(color: color) }
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
      @peg = "[*]".colorize(:color => @color) + " "
    end

  end

  def to_s
    return @peg
  end
end

g = Game.new
g.play
