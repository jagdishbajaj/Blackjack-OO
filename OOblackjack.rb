# BLACKJACK GAME - OBJECT ORIENTED
# Written 

# Identify major Nouns and abstract their behaviour into Classes
# 1)Deck 2)Card 3)Player 4)Dealer
# DECK variables = cardcount
# CARD

require 'pry'

class Deck
	attr_accessor :cards
	def initialize
		@cards = [ ]
		["S", "C", "D", "H"].each do |suit|
			['A','2','3','4','5','6','7','8','9','10','J','Q','K'].each do |face_value|
				@cards << Card.new(suit, face_value)
			end
		end
		shufflecards!
	end

	def shufflecards!
		cards.shuffle!
	end

	def dealacard
    	cards.pop				# this pops the first card from the Deck after it has been shuffled
   	end

	def size
		cards.size				# this tells us how many cards remain in the deck
	end
end

class Card
	attr_accessor :suit, :face_value

	def initialize (s,fv)
		@suit=s
		@face_value=fv
	end

	def seecard
		"The #{face_value} of #{find_suit}"			# we are using find_suit to expand to the full name of the suit
	end

	def find_suit
		suitval = case suit 						# the variable suitval gets assigned to the output of the case statement
					when 'H' then "Hearts"
					when 'D' then "Diamonds"
					when 'S' then "Spades"
					when 'C' then "Clubs"
				  end
		suitval										# we now return the value of suitval
	end

	def to_s					# this "to_s" method is the default output method and we are going to point it to our own prettier method
		seecard
	end
end

module Hand 					# contains all the common code to both Player and Dealer objects

	def show_hand				# shows the hand of cards for each person
		puts "--- #{name}'s Hand is ---"
		cards.each do |card|
			puts "--> #{card}"
		end
	end

	def total 					# adds up the total of all the cards
		face_values = cards.map{|card| card.face_value}			# the .map function will give us just the face value, we don't need the suit
		puts "Face values are #{face_values}"
		total = 0				# our local variable for total

		face_values.each do |fv|
			if fv == 'A'		# we have an Ace
				total += 11		# add 11 for an Ace
			else
				total += (fv.to_i == 0 ? 10 : fv.to_i)			# if the integer value is zero, add 10 because we have a J, Q, K -- else add the integer value
			end
			puts "Our running total is #{total}"
		end

		# Now lets correct for Aces. There could be multiple aces so we are going to iterate through face_values and find them
		# the .select will pick out all the Aces, we count how many and iterate that many times

		face_values.select{|fv| fv == 'A'}.count.times do 
			break if total <=21			# if the total is below 21, leave the loop
			total -= 10					# if not, reduce the total by 10 so that we treat each Ace as a 1, not 11
		end
		puts "---#{name}'s total is #{total}"
	end

	def add_card (new_card)			# adds a new card to the Hand
		cards << new_card
	end

	# this function will simply return a true or false because of the ? based on the total of the hand
	def is_busted?
		total > Blackjack::BLACKJACK_BUST
	end
	binding.pry
end

class Player
	include Hand
	attr_accessor :name, :cards		# This setsup the setters and getters allowing this variable to be set and accessed
	def initialize (n)				# Pass me the name of the Player
		@name=n
		@cards=[ ]					# This is the blank array where the cards for the Player will be dealt, initialized to a blank
	end

	# this function show_flop is really created for the Dealer because we don't show all the dealers cards, just the second one
	# so in the case of the player, we simply default show_flop to point to show_hand, which is contained inside the Hand module
	# by adding show_flop here, we are overwriting the show_flop in the module Hand
	def show_flop
		show_hand
	end
	puts "DEALER OBJECT CREATED"
	binding.pry
end

class Dealer
	include Hand
	attr_accessor :name, :cards
	def initialize
		@name="Bob the Dealer"		# Bob is our dealer
		@cards=[ ]					# Bob has blank array to store his cards
	end

	def show_flop
		puts "--- Bob the Dealer has ---"
		puts "--- first card remains hidden ---"
		puts "--- second card is #{cards[1]}"		# elements start at 0, so 1 is really the second card
	end
end

# Now this is our engine, also an object containing various functions
class Blackjack
	attr_accessor :deck, :player, :dealer
	BLACKJACK_BUST = 21			# this sets the bust rule to 21
	DEALER_HIT_MIN = 17			# this sets the minimum hit for the Dealer to 17

	def initialize
		@deck = Deck.new 		# this will initialize the Deck object to a new one
		@player = Player.new("Player") 	# this will initialize a new Player object
		@dealer = Dealer.new 	# this will initialize a new Dealer
	end

	def get_player_name
		puts "What is your name?"
		player.name = gets.chomp
	end

	def deal_cards				# these are the first cards we will deal to start the game
		player.add_card (deck.dealacard)
		dealer.add_card (deck.dealacard)
		player.add_card (deck.dealacard)
		dealer.add_card (deck.dealacard)
	end

	def show_flop
		player.show_flop
		dealer.show_flop
	end

	# this function will check if Blackjack has been reached or hand is Busted
	def blackjack_or_bust?(player_or_dealer) 		# Ruby allows either player or dealer to be passed
		if player_or_dealer.total == BLACKJACK_BUST
			if player_or_dealer.is_a? (Player)
				puts "Congratulations #{player.name}, you hit Blackjack"
			else
				puts "Sorry, Dealer hit Blackjack, #{player.name} loses."
			end
			play_again?
		elsif player_or_dealer.is_busted?
				if player_or_dealer.is_a?(Dealer)
					puts "Dealer busted, #{player.name} wins!"
				else
					puts "Sorry you busted, Dealer wins..."
				end
				play_again?
		end
	end

	def player_turn
		puts "#{player.name}'s turn now..."
		puts '=============pry==============='
		binding.pry
		blackjack_or_bust?(player)
		puts player.is.busted?
		while !player.is_busted?
			puts "Do you want to Hit or Stay, please enter 1) Hit or 2) Stay"
			hit_or_stay = gets.chomp
			if !['1', '2'].include?hit_or_stay
				puts "You must enter a 1 or 2"
				next
			end

			if hit_or_stay == '2'
				puts "#{player.name} has chosen to Stay"
				break
			end

			# the following logic is for a Hit
			new_card = deck.dealacard
			puts "New card dealt to #{player.name} --- #{new_card}"
			player.add_card (new_card)
			puts "#{player.name}'s total now stands at: #{player.total}"

			blackjack_or_bust?(player)	#lets find out how the player is doing after the new card
		end
		puts "#{player.name} stays at #{player.total}"
	end

	def dealer_turn
		puts "Dealer's turn now..."
		blackjack_or_bust?(dealer)
		while dealer.total < DEALER_HIT_MIN			# keep dealing cards if dealer is below the MIN
			new_card = deck.dealacard
			puts "New card dealt to Dealer --- #{new_card}"
			dealer.add_card (new_card)
			puts "Dealer's total now stands at: #{dealer.total}"
			blackjack_or_bust?(dealer)
		end
		puts "Dealer stays at #{dealer.total}"
	end

	def who_won?
		if dealer.total > player.total
			puts "Sorry, #{player.name}, Dealer won"
		elsif player.total > dealer.total
				puts "Congratulations #{player.name}, you win!"
		else
			puts "Oops, its a Tie, split the cash..."
		end
		play_again?
	end

	def play_again?
		puts " "
		puts "Do you want to play again?  1) Sure  2) Nah, I'm done..."
		if gets.chomp == '1'
			puts "OK, here we go again, new game starting ..."
			puts " "
			deck = Deck.new
			player.Cards = [ ]
			dealer.cards = [ ]
			startgame
		else
			puts "Ta ta, do come again!"
			exit
		end
	end

	def startgame
		get_player_name
		deal_cards
		show_flop
		player_turn
		dealer_turn
		who_won?
	end
end

game = Blackjack.new
game.startgame