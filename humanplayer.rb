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
		puts "Enter move [domino][place] (q to quit, p to pull new domino)"

		loop do
			print '> '
			input = gets.chomp.downcase
			if input[0] == 'p'
				return 'p'
			end
			if input[0] == 'q'
				puts 'Quit.'
				exit 0
			end
			d, place = input.scan(/^([0-9]+)(.)/).first
			next unless is_numeric?(d)
			next unless ['n','e','w','s'].include?(place)
			domino = hand.get(d.to_i)
			next if domino.nil?
			return place, domino
		end
	end
end

