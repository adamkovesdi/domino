#!/usr/bin/env ruby
#
# Random player for domino engine by adamkov

require_relative 'domino'

class Randomplayer
	attr_reader :name

	def initialize(name = nil)
		names = %w(Curtis Tom Delia Stuart Ross Gabe Juan Damir Marco Lily Judit Paul John George Michael Samantha Betty Dorothy Monica)
		name ||= names.sample
		@name = name
	end

	def act(table, hand)
		oe = table.openends

		if oe.empty?
			# all ends free, play highest double or random domino
			domino = hand.highestdouble
			domino = hand.sample if domino.nil?
			place = 'e'
			return place, domino
		end

		validmoves = Hash.new
		# valid moves hash <key: domino> => [ 'e', 's', 'w'... etc]

		oe.each do |e,num|
			if hand.has?(num)
				doms = hand.getdominos(num)
				doms.each do |d|
					arr = validmoves[d]
					if arr.nil?
						validmoves[d] = [e]
					else
						arr << e
					end
				end
			end
		end

		domino = validmoves.keys.sample
		if domino.nil?
			# no valid moves, pull
			place = 'p'
		else
			# play a random move
			place = validmoves[domino].sample
		end
		# puts "aiming for score #{table.calculatescoreforstep(domino,place)}"
		return place, domino
	end
end

