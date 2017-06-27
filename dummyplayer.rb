#!/usr/bin/env ruby
#
# Dummy player for domino engine by adamkov
#

class Dummyplayer
	def act(table, hand)
		place = 'e'
		domino = hand.sample
		return place, domino
	end
end
