# frozen_string_literal: true
# Create a class Player that holds player information (name, number of mistakes left, current letter)
# Create a class Game that is used to actually play the game

# First, the intro is written out. User is welcomed and told about basic rules of the game.
# Then, word between 5 and 12 characters is randomly selected from a file.
# Game should be played until player has guessed the secret word or has no more attempts.

# There is a display of how many more incorrect guesses does the user have.
# Also, correct letters are displayed like _ r o g r a _ _ i n g.
# User is able to see what letters he already entered

# Every turn, allow the player to make a guess of a letter. It should be case insensitive.
# Update the display to reflect whether the letter was correct or incorrect. 
# If out of guesses, the player should lose.

# There should be a congratulations message if player has won

# At the start of any turn, instead of making a guess the player should also have the option to save the game

# When the program first loads, there is an option that allows user to open one of his saved games,
# which should jump him exactly back to where he was when he saved.

module Hangman
  require 'yaml'

  MAX_MISTAKES = 7

  class Player
    attr_accessor :name, :mistakes, :current_letter, :letters
    def initialize(name = "Unknown")
      @name = name
      @mistakes = 0
      @current_letter = ''
      @letters = []
    end
  end

  class Game
    attr_accessor :player, :secret_word, :do_save, :do_load
    def initialize
      @player = Player.new
      @secret_word = '' 
      @do_save = false
      @do_load = false
    end

    def play
      write_intro

      dictionary = get_words
      @secret_word = select_secret_word(dictionary)

      @do_load = ask_to_load
      file_to_load = choose_file if do_load
      loaded_game = load_file(file_to_load) if file_to_load

      from_yaml(loaded_game)

      until over? || won?
        display_mistakes(player)

        puts display_correct_letters(player.letters, secret_word).join(' ')

        display_all_guesses(player.letters)

        @do_save = ask_to_save
        if do_save
          save_file
          break
        end

        enter_letter(player)

        check_letter(player.current_letter, secret_word)
      end

      output
    end

    def over?
      player.mistakes == MAX_MISTAKES
    end

    def won?
      !display_correct_letters(player.letters, secret_word).include?('_')
    end

    def to_yaml
      YAML.dump(
        {
          player: {
            mistakes: @player.mistakes,
            letters: @player.letters
          },
          secret_word: @secret_word
        }
      )
    end

    def from_yaml(loaded_game)
      if loaded_game
        data = YAML.load(loaded_game)
        @secret_word = data[:secret_word]
        @player.mistakes = data[:player][:mistakes]
        @player.letters.append(data[:player][:letters]).flatten!
      end
    end
  end

  def write_intro
    puts 'Welcome to HANGMAN!'
    puts 'Please enter your name: '
    player.name = gets.chomp

    puts ''
    puts "Hello, #{player.name}. You have #{MAX_MISTAKES} allowed mistakes to guess our word."
    puts 'Good luck!'
    puts ''
  end

  def output
    puts ''
    if won?
      puts "Congratulations. You won!"
      puts ''
      puts display_correct_letters(player.letters, secret_word).join(' ')
    elsif over?
      puts "I'm sorry. You are out of moves. :(" 
      puts ''
      puts "Correct word was: #{secret_word}"
    end
  end

  def display_mistakes(player)
    puts ''
    puts "Mistakes made: #{player.mistakes}/#{MAX_MISTAKES}"
    puts ''
  end

  def display_correct_letters(letters, word)
    mapped_word_array = word.split('').map do |letter|
      if letters.include?(letter)
        letter
      else
        '_'
      end
    end
  end

  def display_all_guesses(letters)
    puts ''
    puts "Your guesses so far: #{letters.join(', ')}"
    puts ''
    puts '-------------------------------------------'
    puts ''
  end

  def get_words
    if File.exist?('words.txt')
      File.readlines('words.txt')
    end
  end

  def select_secret_word(words)
    words.select {|word| word.delete("\n").length.between?(5, 12)}.sample.delete("\n")
  end

  def enter_letter(player)
    puts 'Please guess the letter: '
    player.current_letter = gets.chomp.downcase
    while player.letters.include?(player.current_letter) || !('a'..'z').include?(player.current_letter)
      puts ''
      puts 'Try again: '
      player.current_letter = gets.chomp.downcase
    end
  end

  def check_letter(letter, word)
    unless word.include?(letter)
      player.mistakes += 1
    end
    player.letters.push(letter)
  end

  def ask_to_save
    puts "Would you like to exit and save the game? (y/n)"
    do_save = gets.chomp.downcase
    until ['y', 'n'].include?(do_save)
      puts "Would you like to exit and save the game? (y/n)"
      do_save = gets.chomp.downcase
    end
    puts ''

    return do_save == 'y' ? true : false
  end

  def ask_to_load
    puts "Would you like to load one of your saved games? (y/n)"
    do_load = gets.chomp.downcase
    until ['y', 'n'].include?(do_load)
      puts "Would you like to load one of your saved games? (y/n)"
      do_load = gets.chomp.downcase
    end
    puts ''

    return do_load == 'y' ? true : false
  end

  def save_file
    Dir.mkdir('saves') unless Dir.exist?('saves')
    filename = "saves/save_#{player.name}.yaml"

    File.open(filename, 'w') do |file|
      file.puts to_yaml
    end
  end

  def load_file(filename)
    unless Dir.empty?('saves')
      File.read("./saves/#{filename.concat('.yaml')}")
    end
  end

  def choose_file
    files = []
    d = Dir.new('saves')
    if Dir.exist?('saves') && !Dir.empty?('saves')
      d.each_child do |file| 
        puts "#{File.basename(file, '.yaml')}"
        files.push(File.basename(file, '.yaml'))
      end
      puts ''
      puts "Enter the file name you want to load: "
      file_to_load = gets.chomp
      until files.include?(file_to_load)
        puts "Enter the file name you want to load: "
        file_to_load = gets.chomp
      end
      file_to_load
    else
      puts "There is nothing to load"
    end
  end
end

include Hangman
game = Game.new
game.play