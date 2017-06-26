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
		@head == @tail
	end

	def has?(num)
		(@head == num) || (@tail == num)
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
	attr_accessor :firstdouble

	def spinnerclosed?
		return false if firstdouble.nil?
		return false if @dominos.empty?
		i = @dominos.find_index(firstdouble)
		if (i > 0)  && (i < @dominos.count-1)
			return true
		else
			return false
		end
	end

	def getvalue
		head = @dominos.last
		tail = @dominos.first
		val = 0
		if head == tail
			# first element in stack does not count
			return val 
		end
		if head.double?
			val += head.value
		else
			val += head.head
		end
		if tail.double?
			val += tail.value
		else
			val += tail.tail
		end
		val
	end

	def getscore
		val = getvalue
		if val % 5 == 0
			val
		else
			0
		end
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
			@firstdouble = domino if domino.double?
			return true
		end
		if domino.head == bottomnumber
			@dominos.unshift(domino)
			@firstdouble = domino if domino.double?
			return true
		end
		if domino.tail == bottomnumber
			domino.flip
			@firstdouble = domino if domino.double?
			@dominos.unshift(domino)
			return true
		end
		return false
	end

	def addhead(domino)
		if empty?
			@dominos.push(domino)
			@firstdouble = domino if domino.double?
			return true
		end
		if domino.tail == topnumber
			@dominos.push(domino)
			@firstdouble = domino if domino.double?
			return true
		end
		if domino.head == topnumber
			domino.flip
			@firstdouble = domino if domino.double?
			@dominos.push(domino)
			return true
		end
		return false
	end

	def getscorehead(domino)
		return nil unless legalhead(domino)
		addhead(domino)
		s = getscore
		delete(domino)
		s
	end

	def getscoretail(domino)
		return nil unless legaltail(domino)
		addtail(domino)
		s = getscore
		delete(domino)
		s
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
		"Stack: #{self.to_s} (V#{getvalue}/S#{getscore}) D: #{firstdouble}"
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
		oe['n']=@vertical.topnumber if @horizontal.spinnerclosed?
		oe['s']=@vertical.bottomnumber if @horizontal.spinnerclosed?
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
		if @horizontal.spinnerclosed? && @vertical.empty?
			@vertical.add(@horizontal.firstdouble)
			@vertical.firstdouble = @horizontal.firstdouble
		end
		ret
	end
end

