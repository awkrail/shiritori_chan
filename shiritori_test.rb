# -*- coding: utf-8 -*-
require 'csv'

#もしもデータに敗北の原因があれば返り値を1にして,1のときにshiritori_flowで処理をする。

class User
	def initialize(user_input)
		@user_input = user_input
		@used_words = []
		@gojuon = []
	end

	def csv_reader
		tmp_csv_ary = []

		CSV.foreach('csvdata/shiritori_used.csv') do |row|
			tmp_csv_ary.push(row)
		end

		tmp_csv_ary.each do |row|
			first_word,second_word = row[0],row[1]
			@used_words.push(first_word)
			@used_words.push(second_word)
		end
	end

	def shaping_word
		## ユーザの入力の整形をする
		@user_input = @user_input.strip
		user_message = @user_input.tr('ァ-ン','ぁ-ん')
		@user_answer = user_message #ユーザの答えを格納する
		last_word = user_message[-1]
		return last_word
		##
	end

	def rule_check(last_word)
		##
		# => 最後の言葉が「ん」ではないか、使われた言葉を使っていないか、(ユーザの敗北). 五十音の中に収まっているか(ユーザに警告)をチェック.
		# => !important 評価の順番が大切
		#
		## ユーザとしりとりが続くという意味でのstatus_number (=2)
		CSV.foreach('csvdata/shiritori.csv') do |row|
			@gojuon.push(row[0])
		end

		@gojuon.each do |word|
			if word == last_word
				puts 'hoge'
				@status_number = 0
				break;
			else
				@status_number = 2
			end
		end

		# => 敗北するときは@status_number = 1です。
		if last_word == 'ん' 
			@status_number = 1
		end 

		@used_words.each do |word|
			if word == @user_input
				@status_number = 1
			end
		end


		unless @status_number == 1 || @status_number == 2
		@status_number = 0
		end	
	end

	def input_check
		csv_reader #使われた言葉を配列に入れる
		last_word = shaping_word #ユーザの入力を整形するメソッド
		rule_check(last_word) 

		if @status_number == 1
			return 'あなたの負けです'
		end

		if @status_number == 2
			return '五十音の中から発言してください'
		end

		if @status_number == 0
			return user_answer = @user_answer
		end
	end

	def response
	end
end

puts '入力してください:'
user_input = ARGV[0]
user_data = User.new(user_input)
data = user_data.input_check
puts data


class Muno
	def initialize(muno_input,user_input)
		@muno_input = muno_input
		@user_input = user_input
	end

	def csv_load
	end

	def making_hash
	end

	def response
	end
end

class ShiritoriFlow
	def initialize(user_input,muno_input)
		@user_input = user_input
		@muno_input = muno_input
		@flag = false
	end

	def check_flag
		 if @user_input == 'しりとり'
		 	@flag = true
		 end
	end

	def judge
		if check_flag

		end
	end
end

