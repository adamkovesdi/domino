#!/usr/bin/env ruby

require_relative 'domino'

by = Boneyard.new
h = Hand.new
t = Table.new

7.times do
	h.add(by.pull)
end

command = ''
while command != 'q'
	h.display
	t.display
	puts t.openends
	print '> '
	command = gets.chomp
	next if command == 'q'
	if command == 'p'
		d = by.pull
		h.add(d) unless d.nil?
		next
	end
	domino = h.get(command[0].to_i)
	next if domino.nil?
	ret = t.play(domino,command[1])
	h.delete(domino) if ret
end

