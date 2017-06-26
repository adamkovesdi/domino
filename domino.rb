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
end

class Hand < DominoHolder
	def getdoubles
		@dominos.select { |d| d.double? }
	end

	def highestdouble
		getdoubles.max
	end

	def get(index)
		@dominos[index]
	end

	def display
		print 'Hand: '
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
		puts str 
	end

	def str
		"Stack: #{self.to_s}"
	end
end

class Table
	attr_reader :spinner

	def initialize
		@horizontal = Stack.new
		@vertical = Stack.new
	end

	def display
		puts "W #{@horizontal.str} E"
		puts "S #{@vertical.str} N"
	end

	def openends
		oe = Hash.new(99)
		oe['n']=@vertical.topnumber
		oe['s']=@vertical.bottomnumber
		oe['e']=@horizontal.topnumber
		oe['w']=@horizontal.bottomnumber
		oe
	end

	def play(domino, quarter)
		case quarter
		when 'n'
			ret = @vertical.addhead(domino) if @vertical.legalhead(domino)
		when 's'
			ret = @vertical.addtail(domino) if @vertical.legaltail(domino)
		when 'e'
			ret = @horizontal.addhead(domino) if @horizontal.legalhead(domino)
		when 'w'
			ret = @horizontal.addtail(domino) if @horizontal.legaltail(domino)
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
end

