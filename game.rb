#!/usr/bin/env ruby

require_relative 'domino'
require_relative 'randomplayer'
require_relative 'humanplayer'

class DominoGame
	attr_reader :winner

	def initialize(playercount = 2)
		abort("*** Invalid player count #{playercount} [2-4]") if playercount > 4 || playercount < 2
		@winner = nil
		@passcount = 0
		@playercount = playercount
		@table = Table.new
		@boneyard = Boneyard.new
		@players = Array.new
		@hands = Array.new
		names = %w(Curtis Tom Delia Stuart Ross Gabe Juan Damir Marco Lily Judit Paul John George Michael Samantha Betty Dorothy Monica)
		@playercount.times do
			@players << Randomplayer.new(names.sample)
			@hands << Hand.new
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
	end

	def turn(player, hand)
		# return value = play, pass, win
		# puts "#{player.name}'s turn"
		while true
			if @table.canplay?(hand)
				place, domino = player.act(@table, hand)
				ret = @table.play(domino,place)
				unless ret
					abort("*** Fault detected #{player.name} playing #{domino} to #{place.upcase} Invalid move.")
				end
				hand.delete(domino)
				puts "#{player.name} played #{domino} in #{place.upcase}"
				# debug
				puts "Score: #{@table.getscore}"
				return 'win' if hand.empty?
				return 'play'
			end
			if @boneyard.empty?
				puts "#{player.name} could not play - no dominos left"
				return 'pass'
			else
				dom = @boneyard.pull
				puts "#{player.name} pulled #{dom}"
				hand.add(dom)
			end
		end
	end	

	def summary
		puts '--------'
		@players.each_with_index do |p,i|
			print p.name + ' ' ; @hands[i].display
		end
		@table.display
		if winner.nil?
			puts "No one win, blocked game"
		else
			puts "The winner is #{winner.name}"
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
			puts "#{@players[0].name} #{res}"
			@winner = @players[0]
			return false
		when 'play'
			@passcount = 0
			nextturn
			return true
		end
	end

end

g = DominoGame.new(4) ; while g.round ; end ; g.summary

