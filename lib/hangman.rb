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
    attr_accessor :player, :secret_word, :do_save
    def initialize
      @player = Player.new
      @secret_word = '' 
      @do_save = false
    end

    def play
      write_intro

      dictionary = get_words
      @secret_word = select_secret_word(dictionary)

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
          player: @player,
          secret_word: @secret_word
        }
      )
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

  def save_file
    Dir.mkdir('saves') unless Dir.exist?('saves')
    filename = "saves/save_#{player.name}.yaml"

    File.open(filename, 'w') do |file|
      file.puts to_yaml
    end
  end
end

include Hangman
game = Game.new
game.play