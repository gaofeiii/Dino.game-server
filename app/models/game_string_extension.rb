# encoding: utf-8
module GameStringExtension
	DOWNCASE_LETTERS = ('a'..'z').to_a
	UPCASE_LETTERS = ('A'..'Z').to_a
	NUMBERS = ('0'..'9').to_a

	LETTERS = DOWNCASE_LETTERS + UPCASE_LETTERS
	CHARACTORS = DOWNCASE_LETTERS + UPCASE_LETTERS + NUMBERS

	module ClassMethods
		@@sensitive_words = Array.new

		def sample(n = 1, args = {})
			str = new
			1.upto(n).each do
				if args.empty?
					str << CHARACTORS.sample
				end
			end
			return str
		end

		def sensitive_words
			if @@sensitive_words.empty?
				load_sensitive_words!
			end
			@@sensitive_words
		end

		def load_sensitive_words!
			@@sensitive_words.clear
			book = Excelx.new("#{Rails.root}/const/sensitive_words.xlsx")

			@@sensitive_words = 1.upto(book.last_row).map do |i|
				word = book.cell(i, 'A')
				Regexp.new word
			end
		end
	end
	
	module InstanceMethods
		
		def sensitive?
			self.class.sensitive_words.each do |word|
				return true if word =~ self
			end
			false
		end

		def filter!
			self.class.sensitive_words.each do |sensi_word|
				start = self =~ sensi_word
				if start
					self[start, self.size] = '*' * (self.size - start)
				end
			end
			self
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end