#!/usr/bin/env ruby

class Domino
	attr_reader :head
	attr_reader :tail

	def initialize(tail, head)
		@head = head
		@tail = tail
	end

	def flip
		@head, @tail = @tail, @head
	end

	def double?
		return (@head == @tail)
	end

	def has?(num)
		return ((@head == num) || (@tail == num))
	end

	def to_s
		"#{@tail}|#{@head}"	
	end

	def value
		@head + @tail
	end

	def <=>(another)
		value <=> another.value
	end
end

class DominoHolder
	def initialize
		@dominos = Array.new
	end

	def each(&block)
		@dominos.each(&block)
	end

	def hasdomino?(domino)
		@dominos.each { |d| return true if d == domino }
		return false
	end

	def count
		@dominos.length
	end

	def pull
		@dominos.pop
	end

	def add(o)
		@dominos << o
	end

	def delete(domino)
		@dominos.delete(domino)
	end

	def sample
		@dominos.sample
	end

	def empty?
		@dominos.empty?
	end

	def has?(num)
		@dominos.each { |d| return true if d.has?(num) }
		return false
	end

	def to_s 
		@dominos.join(' ')
	end
end

class Boneyard < DominoHolder
	def initialize
		@dominos = Array.new
		for x in 0..6 do
			for y in 0..x do
				@dominos << Domino.new(x,y)
			end
		end
		shuffle
	end

	def shuffle
		@dominos.shuffle!
	end

	def display
		puts "Boneyard: #{self.to_s}"
	end
end

class Hand < DominoHolder
	def getdoubles
		@dominos.select { |d| d.double? }
	end

	def highestdouble
		getdoubles.max
	end

	def getdominos(number)
		@dominos.select { |d| d.has?(number) }
	end

	def get(index)
		@dominos[index]
	end

	def display
		@dominos.each_with_index { |dom,i| print "#{i} [#{dom}] " }
		puts
	end
end

class Stack < DominoHolder
	def closed?(domino)
		return false if @dominos.empty?
		return false unless hasdomino?(domino)
		i = @dominos.find_index(domino)
		return ((i > 0)  && (i < @dominos.count-1))
	end

	def topnumber
		return nil if @dominos.empty?
		@dominos.last.head
	end

	def bottomnumber
		return nil if @dominos.empty?
		@dominos.first.tail
	end

	def addtail(domino)
		if empty?
			@dominos.unshift(domino)
			return true
		end
		if domino.head == bottomnumber
			@dominos.unshift(domino)
			return true
		end
		if domino.tail == bottomnumber
			domino.flip
			@dominos.unshift(domino)
			return true
		end
		return false
	end

	def addhead(domino)
		if empty?
			@dominos.push(domino)
			return true
		end
		if domino.tail == topnumber
			@dominos.push(domino)
			return true
		end
		if domino.head == topnumber
			domino.flip
			@dominos.push(domino)
			return true
		end
		return false
	end

	def legalhead(domino)
		return true if empty?
		return true if domino.has?(topnumber)
		return false
	end

	def legaltail(domino)
		return true if empty?
		return true if domino.has?(bottomnumber)
		return false
	end

	def display
		puts self.to_s 
	end

end

class Table
	attr_reader :spinner

	def initialize
		@horizontal = Stack.new
		@vertical = Stack.new
	end

	def display
		puts "W #{@horizontal} E"
		puts "S #{@vertical} N"
	end

	def openends
		# hash of playable ends - entire hash is empty if the table is empty
		oe = Hash.new
		oe['n']=@vertical.topnumber unless @vertical.topnumber.nil?
		oe['s']=@vertical.bottomnumber unless @vertical.bottomnumber.nil?
		oe['e']=@horizontal.topnumber unless @horizontal.topnumber.nil?
		oe['w']=@horizontal.bottomnumber unless @horizontal.bottomnumber.nil?
		oe
	end

	def play(domino, quarter)
		case quarter
		when 'n'
			if @vertical.empty?
				ret = @vertical.addhead(domino) if @horizontal.empty?
			else
				ret = @vertical.addhead(domino) if @vertical.legalhead(domino)
			end
		when 's'
			if @vertical.empty?
				ret = @vertical.addtail(domino) if @horizontal.empty?
			else
				ret = @vertical.addtail(domino) if @vertical.legaltail(domino)
			end
		when 'e'
			if @horizontal.empty?
				ret = @horizontal.addhead(domino) if @vertical.empty?
			else
				ret = @horizontal.addhead(domino) if @horizontal.legalhead(domino)
			end
		when 'w'
			if @horizontal.empty?
				ret = @horizontal.addtail(domino) if @vertical.empty?
			else
				ret = @horizontal.addtail(domino) if @horizontal.legaltail(domino)
			end
		else
			return
		end
		if ret && domino.double? && spinner.nil?
			@spinner = domino
		end

		if ret && !@spinner.nil?
			@horizontal.addtail(@spinner) if (!@horizontal.hasdomino?(@spinner)) && (@vertical.closed?(@spinner))
			@vertical.addtail(@spinner) if (!@vertical.hasdomino?(@spinner)) && (@horizontal.closed?(@spinner))
		end

		ret
	end

	def canplay?(hand)
		oe = openends
		return true if oe.empty?
		oe.each do |dir, num|
			return true if hand.has?(num)
		end
		return false
	end

end

