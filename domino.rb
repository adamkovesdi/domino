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

	def topdomino
		return nil if @dominos.empty?
		@dominos.last
	end

	def bottomdomino
		return nil if @dominos.empty?
		@dominos.first
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

	def legalhead?(domino)
		return true if empty?
		return true if domino.has?(topnumber)
		return false
	end

	def legaltail?(domino)
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

	def to_s
		"W #{@horizontal} E\nS #{@vertical} N"
	end

	def display
		puts self.to_s
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

	def legalmove?(domino, quarter)
		case quarter
		when 'n'
			if @vertical.empty?
				return true if @horizontal.empty?
			else
				return true if @vertical.legalhead?(domino)
			end
		when 's'
			if @vertical.empty?
				return true if @horizontal.empty?
			else
				return true if @vertical.legaltail?(domino)
			end
		when 'e'
			if @horizontal.empty?
				return true if @vertical.empty?
			else
				return true if @horizontal.legalhead?(domino)
			end
		when 'w'
			if @horizontal.empty?
				return true if @vertical.empty?
			else
				return true if @horizontal.legaltail?(domino)
			end
		else
			return false
		end
	end

	def play(domino, dir)
		return false unless legalmove?(domino,dir)
		case dir
		when 'n'
				ret = @vertical.addhead(domino)
		when 's'
				ret = @vertical.addtail(domino)
		when 'e'
				ret = @horizontal.addhead(domino)
		when 'w'
				ret = @horizontal.addtail(domino)
		else
			return false
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


	def calculatescoreforstep(domino,dir)
		# returns value of board with the domino
		return false unless legalmove?(domino,dir)
		case dir
		when 'n'
				@vertical.addhead(domino)
		when 's'
				@vertical.addtail(domino)
		when 'e'
				@horizontal.addhead(domino)
		when 'w'
				@horizontal.addtail(domino)
		else
			# should not happen
			return false
		end
		retval = getscore
		retval = 0 unless retval % 5 == 0
		@horizontal.delete(domino)
		@vertical.delete(domino)
		return retval
	end


	def getscore
		# returns the score of the whole board
		scores = Hash.new
		scores['n']=@vertical.topnumber
		scores['n'] = scores['n'] * 2 if !@vertical.topdomino.nil? && @vertical.topdomino.double?
		scores['s']=@vertical.bottomnumber
		scores['s'] = scores['s'] * 2 if !@vertical.bottomdomino.nil? && @vertical.bottomdomino.double?
		scores['e']=@horizontal.topnumber
		scores['e'] = scores['e'] * 2 if !@horizontal.topdomino.nil? && @horizontal.topdomino.double?
		scores['w']=@horizontal.bottomnumber
		scores['w'] = scores['w'] * 2 if !@horizontal.bottomdomino.nil? && @horizontal.bottomdomino.double?
		scores.delete_if { |k,v| v.nil? }

		if @vertical.topdomino == @spinner
			scores.delete('n') if @horizontal.closed?(@spinner)
		end
		if @vertical.bottomdomino == @spinner
			scores.delete('s') if @horizontal.closed?(@spinner)
		end
		if @horizontal.topdomino == @spinner
			scores.delete('e') if @vertical.closed?(@spinner)
		end
		if @horizontal.bottomdomino == @spinner
			scores.delete('w') if @vertical.closed?(@spinner)
		end

		if @vertical.topdomino == @vertical.bottomdomino
			scores.delete('n')
			scores.delete('s')
		end
		if @horizontal.topdomino == @horizontal.bottomdomino
			scores.delete('w')
			scores.delete('e')
		end

		score = scores.values.inject(0, :+)
		score = 0 unless score % 5 == 0
		score
		
	end

end

