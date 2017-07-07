#!/usr/bin/env ruby

require_relative 'domino'
require_relative 'randomplayer'
require_relative 'humanplayer'
require_relative 'greedyplayer'

class DominoGame
	attr_reader :winner

	def initialize(playercount = 2)
		abort("*** Invalid player count #{playercount} [2-4]") if playercount > 4 || playercount < 2
		players = %w(r r g r)
		@winner = nil
		@passcount = 0
		@playercount = playercount
		@table = Table.new
		@boneyard = Boneyard.new
		@players = Array.new
		@hands = Array.new
		@scores = Array.new
		@playercount.times do
			case players.shift
			when 'g'
				@players << Greedyplayer.new
			when 'h'
				@players << Humanplayer.new
			else
				@players << Randomplayer.new
			end
			@hands << Hand.new
			@scores << 0
		end
		7.times do
			@hands.each do |h|
				h.add(@boneyard.pull)
			end
		end
	end

	def nextturn
		@players.rotate!
		@hands.rotate!
		@scores.rotate!
	end

	def turn(player, hand)
		# return value = play, pass, win
		while true
			if @table.canplay?(hand)
				place, domino = player.act(@table, hand)
				ret = @table.play(domino,place)
				unless ret
					abort("*** Fault detected #{player.name} playing #{domino} to #{place.upcase} Invalid move.")
				end
				hand.delete(domino)
				puts "#{player.name} played #{domino} in #{place.upcase} Score: #{@table.getscore}"
				return 'win' if hand.empty?
				return 'play'
			end
			if @boneyard.empty?
				puts "#{player.name} passed"
				return 'pass'
			else
				dom = @boneyard.pull
				puts "#{player.name} pulled #{dom}"
				hand.add(dom)
			end
		end
	end	

	def summary
		puts '---Hands---'
		@players.each_with_index do |p,i|
			print p.name + ' ' ; @hands[i].display
		end
		puts '---Table---'
		@table.display
		if winner.nil?
			puts "No one win, blocked game"
		else
			puts "The winner is #{winner.name}"
		end
		puts '---Scoring---'
		@players.each_with_index do |p,i|
			puts "#{p.name} #{@scores[i]}"
		end
	end

	def round
		res = turn(@players[0], @hands[0])
		case res
		when 'pass'
			@passcount += 1
			if @passcount < @playercount
				nextturn
				return true
			else
				# blocked game
				puts "Blocked game!"
				return false
			end
		when 'win'
			puts "#{@players[0].name} dominoed"
			@winner = @players[0]
			return false
		when 'play'
			@passcount = 0
			@scores[0] += @table.getscore
			nextturn
			return true
		end
	end

end

srand ARGV[0].to_i unless ARGV.nil? 
g = DominoGame.new(4) ; while g.round ; end ; g.summary

