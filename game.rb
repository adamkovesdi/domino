#!/usr/bin/env ruby

require_relative 'domino'
require_relative 'randomplayer'
require_relative 'humanplayer'

class DominoGame
	attr_reader :table
	attr_reader :boneyard
	attr_reader :player1
	attr_reader :player2
	attr_reader :hand1
	attr_reader :hand2

	def initialize
		@table = Table.new
		@boneyard = Boneyard.new
		names = %w(Curtis Tom Delia Stuart Ross Gabe Juan Damir Marco Lily Judit Paul John George Michael Samantha Betty Dorothy Monica)
		@player1 = Randomplayer.new(names.sample)
		@player2 = Randomplayer.new(names.sample)
		# @player2 = Humanplayer.new(names.sample)
		@hand1 = Hand.new
		@hand2 = Hand.new
		7.times do
			@hand1.add(@boneyard.pull)
			@hand2.add(@boneyard.pull)
		end
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

end

g = DominoGame.new

loop do
	res = g.turn(g.player1, g.hand1)
	if res == 'pass' || res == 'win'
		puts "#{g.player1.name} #{res}"
		break
	end
	res = g.turn(g.player2, g.hand2)
	if res == 'pass' || res == 'win'
		puts "#{g.player2.name} #{res}"
		break
	end
end

puts '--------'
print g.player1.name + ' ' ; g.hand1.display
g.table.display
print g.player2.name + ' ' ; g.hand2.display

