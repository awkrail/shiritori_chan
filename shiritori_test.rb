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
		CSV.foreach('csvdata/shiritori_used.csv') do |row|
			@used_words.push(row[0])
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
			if word == @user_answer
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
			csv_writer(@user_answer)
			return user_answer = @user_answer
		end
	end

	def csv_writer(word)
		tmp_ary = []
		tmp_ary.push(word)
		CSV.open('csvdata/shiritori_used.csv','a') do |used_words|			
			used_words << tmp_ary
		end
	end
end



class Muno
	def initialize(user_input)
		@user_input = user_input
		@used_words = []
		@vocablary = {}
	end

	def csv_load
		CSV.foreach('csvdata/shiritori_used.csv') do |row|
			@used_words.push(row[0])
		end
	end

	def making_hash(turn)
		if turn == 1
		CSV.foreach('csvdata/shiritori.csv') do |row|
			gojuon = row.shift
			@vocablary[gojuon] = row
		end
		end
	end

	def response
		##
		# => status_numの言葉の最後を使っているっぽいので、流れが出来てから再度デバッグする形になる。
		##
		if @vocablary.has_key?(@user_input[-1])
			@vocablary.each do |firstword,array|
				if firstword == @user_input[-1]
					response_data = array.shift
					return response_data
					# csvの最初のデータを消す。
				end
			end
		end
	end

	def muno_check(turn)
		csv_load
		making_hash(turn)
		print @vocablary
		response_data = response
	end
end

@turn = 1

loop do
	puts @turn
	puts '入力してください:'
	user_input = gets
	user_data = User.new(user_input)
	data = user_data.input_check
	##ここから人工無脳側の処理を書く
	if @turn == 1
	@muno_data = Muno.new(data) ##最初のターンだけは@vocabraryなどをinitするためにnewする。
	end
	response_data = @muno_data.muno_check(@turn)
	puts response_data
	@turn += 1
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


