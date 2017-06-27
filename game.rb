#!/usr/bin/env ruby

require_relative 'domino'
require_relative 'randomplayer'
require_relative 'humanplayer'

def playeract(player, hand, table, boneyard)
	place, domino = player.act(table, hand)
	if place == 'p'
		if boneyard.count > 0
			dom = boneyard.pull
			hand.add(dom)
			puts "#{player.name} pulled #{dom}"
			return 'pulled' 
		else
			puts "No more dominoes"
			return 'pass'
		end
	else
		result = table.play(domino, place)
		if result
			puts "#{player.name} played #{domino} to #{place}"
			hand.delete(domino)
			if hand.empty?
				return 'win'
			else
				return 'played'
			end
		else
			puts "Invalid move: #{player.name} playing #{domino} to #{place}"
			return 'fault'
			# abort "*** Error in #{player.name} playing #{domino} to #{place}"
		end
	end
end

t = Table.new
by = Boneyard.new

player1 = Randomplayer.new('jozsi')
player2 = Humanplayer.new('pista')
hand1 = Hand.new
hand2 = Hand.new

7.times do
	hand1.add(by.pull)
	hand2.add(by.pull)
end

loop do
	res1 = ''
	res2 = ''
	loop do
		res1 = playeract(player1,hand1,t,by)
		break unless res1 == 'pulled' || res1 == 'fault'
	end
	break if res1 == 'win'
	loop do
		res2 = playeract(player2,hand2,t,by)
		break unless res2 == 'pulled' || res2 == 'fault'
	end
	break if res1 == 'pass' || res2 == 'pass' || res1=='win' || res2=='win'
end

puts '----------results----------'
print 'jozsi '
hand1.display
t.display
print 'pista '
hand2.display
