#!/usr/bin/env ruby

# Bastard random player who just selects one valid move and plays it

require_relative 'domino'

by = Boneyard.new
h = Hand.new
t = Table.new

7.times do
	h.add(by.pull)
end


# d = h.highestdouble
# if d.nil?
# puts "No double"
d = h.sample
# end

t.play(d,'e')
h.delete(d)

loop do
	canplay = true
	while canplay
		oe = t.openends
		validmoves = Hash.new

		oe.each do |e,num|
			if h.has?(num)
				doms = h.getdominos(num)
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

		rdomino = validmoves.keys.sample
		if rdomino.nil?
			# no valid moves, pull at end
			canplay = false
		else
			# play a random move
			dest = validmoves[rdomino].sample
			t.play(rdomino,dest)
			h.delete(rdomino)
		end
	end
	break if by.count == 0
	h.add(by.pull)
end


h.display
t.display
