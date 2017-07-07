#!/usr/bin/env ruby
#
# Greedy player for domino engine by adamkov
#

class Greedyplayer
	attr_reader :name

	def initialize(name = nil)
		names = %w(Dagobert Croesus Trump BillG Ritchie)
		name ||= names.sample
		@name = name
	end

	def act(table, hand)
		domino, place = gethighestscore(table, hand)
		if domino.nil?
			domino = hand.highestdouble
			domino = hand.sample if domino.nil?
			place = 'e'
		end
		return place, domino
	end

	def getlegalmoves(table,hand)
		oe = table.openends
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
		return validmoves
	end

	def getscoresformoves(table, hand)
		# returns array of arrays: [ score, domino , direction ]
		scores = Array.new
		validmoves = getlegalmoves(table,hand)
		validmoves.keys.each do |domino|
			validmoves[domino].each do |dir|
				entry = Array.new
				entry << table.calculatescoreforstep(domino,dir)
				entry << domino
				entry << dir
				scores << entry
			end
		end
		scores
	end

	def gethighestscore(table, hand)
		# maximum selection on scores for moves array
		scores = getscoresformoves(table,hand)
		return if scores.empty?
		scores.sort! { |a,b| a[0] <=> b[0] }
		scores.reverse!
		return scores.first[1], scores.first[2]
	end

end

