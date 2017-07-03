#!/usr/bin/env ruby

require_relative 'domino'
require_relative 'randomplayer'
require_relative 'humanplayer'

class DominoGame
	attr_reader :table
	attr_reader :boneyard
	attr_reader :players
	attr_reader :hands

	def initialize
		@table = Table.new
		@boneyard = Boneyard.new
		@players = Array.new
		@hands = Array.new
		names = %w(Curtis Tom Delia Stuart Ross Gabe Juan Damir Marco Lily Judit Paul John George Michael Samantha Betty Dorothy Monica)
		3.times do
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

end

g = DominoGame.new

loop do
	res = g.turn(g.players[0], g.hands[0])
	if res == 'pass' || res == 'win'
		puts "#{g.players[0].name} #{res}"
		break
	end
	g.nextturn
end

puts '--------'
g.players.each_with_index do |p,i|
	print p.name + ' ' ; g.hands[i].display
end
g.table.display

