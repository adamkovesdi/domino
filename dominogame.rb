#!/usr/bin/env ruby
#
# Dominoes All-Five game with spinner
# (c) 2017 by Adam Kovesdi

require_relative 'domino'

require_relative 'randomplayer'
require_relative 'humanplayer'
require_relative 'greedyplayer'

class Dominoplayer
	attr_accessor :ai
	attr_accessor :hand
	attr_accessor :score

	def initialize
		@hand = Hand.new
	end

	def name
		ai.name
	end

end


class Dominogame

	def initialize
		@players = Array.new
		@table = Table.new
		@boneyard = Boneyard.new
	end

	def initplayers(number = 2, typestring = 'r r g r')
		@playercount = number
		playertypes = typestring.split
		number.times do
			player = Dominoplayer.new
			case playertypes.shift
			when 'g'
				player.ai = Greedyplayer.new
			when 'h'
				player.ai = Humanplayer.new
			else
				player.ai = Randomplayer.new
			end
			player.score = 0
			@players << player
		end
	end
	
	def zeroscores
		@players.each { |p| p.score = 0 }
	end

	def randomizeorder
		@players.shuffle!
	end

	def resettableboneyard
		@table = Table.new
		@boneyard = Boneyard.new
		@winner = nil
	end

	def dealhands
		7.times do
			@players.each { |p| p.hand.add(@boneyard.pull) }
		end
	end

	def nextturn
		@players.rotate!
	end

	def scorehands
		unless @winner.nil?
			# winner gets points for all other's hands
			roundscore = 0
			@players.reject{|p| p ==@winner}.each {|ene| roundscore += ene.hand.value}
			@winner.score += roundscore
			# TODO: round to nearest five
		else
			# block: lightest hand gets all other hand's points - own hand's points 
			# TODO: alltogether
		end
	end

	def turn
		# one player move (or pass if can't play), pull until can play
		player = @players.first
		while true
			if @table.canplay?(player.hand)
				place, domino = player.ai.act(@table, player.hand)
				ret = @table.play(domino,place)
				unless ret
					abort("*** Fault detected #{player.name} playing #{domino} to #{place.upcase} Invalid move.")
				end
				player.hand.delete(domino)
				puts "#{player.name} played #{domino} in #{place.upcase} Score: #{@table.getscore}"
				return 'win' if player.hand.empty?
				return 'play'
			end
			if @boneyard.empty?
				puts "#{player.name} passed"
				return 'pass'
			else
				dom = @boneyard.pull
				puts "#{player.name} pulled #{dom}"
				player.hand.add(dom)
			end
		end
	end

	def round
		# until win or block
		while true
			roundcontinues = true
			case turn
			when 'pass'
				@passcount += 1
				if @passcount < @playercount
					nextturn
					roundcontinues = true
				else
					# blocked game
					puts "Blocked game!"
					roundcontinues = false
				end
			when 'win'
				puts "#{@players[0].name} dominoed"
				@winner = @players[0]
				roundcontinues = false
			when 'play'
				@passcount = 0
				@players[0].score += @table.getscore
				nextturn
				roundcontinues = true
			end
			break unless roundcontinues 
		end
	end

	def match(scorelimit = 150)
		# until player reaches 150 score (scorelimit)
		resettableboneyard
		dealhands
		round
		scorehands
	end

	def game
		# whole unit
		# TODO: implement
	end

	def summary
		puts '---Hands---'
		@players.each do |p|
			print p.name + ' ' ; p.hand.display
		end
		puts '---Table---'
		@table.display
		if @winner.nil?
			puts "No one win, blocked game"
		else
			puts "The winner is #{@winner.name}"
		end
		puts '---Scoring---'
		@players.each do|p|
			puts "#{p.name} #{p.score}"
		end
	end
end

srand ARGV[0].to_i unless ARGV[0].nil? 
dg = Dominogame.new
dg.initplayers(3)
dg.match
dg.summary
