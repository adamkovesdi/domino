#!/usr/bin/env ruby
#
# Interactive (human) player for domino engine by adamkov
#

class Humanplayer
	attr_reader :name

	def initialize(name)
		@name = name
	end

	def is_numeric?(obj) 
		obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
	end

	def act(table, hand)
		table.display
		print "Player hand: " ; hand.display
		puts "Enter move [domino][place] (q to quit)"

		loop do
			print '> '
			input = $stdin.gets.strip.downcase
			if input[0] == 'q'
				puts 'Quit.'
				exit 0
			end
			d, place = input.scan(/^([0-9]+)(.)/).first
			next unless is_numeric?(d)
			next unless ['n','e','w','s'].include?(place)
			domino = hand.get(d.to_i)
			next if domino.nil?
			unless table.legalmove?(domino, place)
				puts "Invalid move: #{domino} to #{place.upcase}"
				next
			end
			return place, domino
		end
	end
end

