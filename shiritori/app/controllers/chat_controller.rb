require 'csv'
require 'json'

class ChatController < ApplicationController
  def index
    if params['user'].present?
      #puts params['user']['answer']
      @turn_json = turn_load
      puts @turn_json['turn']
      if params['user']['answer'] == 'しりとり'
        @turn_json['turn'] = 1
        ##このturn_jsonを書き込むメソッドがいる。
        open("#{Rails.root}/public/csvdata/shiritori_turn.json", 'w') do |io|
          JSON.dump(@turn_json, io)
        end
      end
      if @turn_json['turn'] == 1
        @user_input = params['user']['answer']
        @muno_message = GameFlow.new(@user_input).response
      else
        @user_input = params['user']['answer']
        @muno_message = '今日は寒いね。'
    end
    end
  end

private
#もしもデータに敗北の原因があれば返り値を1にして,1のときにshiritori_flowで処理をする。
  def turn_load
    json_file_path = "#{Rails.root}/public/csvdata/shiritori_turn.json"
    json_data = open(json_file_path) do |io|
      JSON.load(io)
    end
    return json_data
  end

  class GameFlow
  def initialize(user_input)
    @user_input = user_input
  end

  def response
    user_obj = User.new(@user_input)
    @user_message = user_obj.input_check
  end
  end


  class User
    def initialize(user_input)
      @user_input = user_input
      @used_words = []
      @gojuon = []
    end

    def csv_reader
      CSV.foreach("#{Rails.root}/public/csvdata/shiritori_used.csv") do |row|
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
      CSV.foreach("#{Rails.root}/public/csvdata/shiritori.csv") do |row|
        @gojuon.push(row[0])
      end

      @gojuon.each do |word|
        if word == last_word
          @status_number = 0
          break
        else
          @status_number = 1002
        end
      end

    # => 敗北するときは@status_number = 1です。
      if last_word == 'ん'
        @status_number = 1001
      end

      @used_words.each do |word|
        if word == @user_answer
          @status_number = 1001
        end
      end

      unless @status_number == 1001 || @status_number == 1002
        @status_number = 0
      end
    end

    def input_check
      csv_reader #使われた言葉を配列に入れる
      last_word = shaping_word #ユーザの入力を整形するメソッド
      rule_check(last_word)

      if @status_number == 1001
        return @status_number
      end

      if @status_number == 1002
        return @status_number
      end

      if @status_number == 0
        csv_writer(@user_answer)
        return user_answer = @user_answer
      end
    end

    def csv_writer(word)
      tmp_ary = []
      tmp_ary.push(word)
      CSV.open("#{Rails.root}/public/csvdata/shiritori_used.csv",'a') do |used_words|
        used_words << tmp_ary
      end
    end

    def reset_csv
      CSV.open("#{Rails.root}/public/csvdata/shiritori_used.csv",'w') do |reset_csv|
        reset_csv << []
      end
    end
  end



 class Muno
  def initialize(user_input)
    @user_input = user_input
    @used_words = []
    @vocabulary = {}
  end

  def csv_load
    CSV.foreach("#{Rails.root}/public/csvdata/shiritori_used.csv") do |row|
      @used_words.push(row[0])
    end
  end

  def making_hash
    CSV.foreach("#{Rails.root}/public/csvdata/shiritori.csv") do |row|
      gojuon = row.shift
      @vocabulary[gojuon] = row
    end
  end

  def response
    ##
    # => status_numの言葉の最後を使っているっぽいので、流れが出来てから再度デバッグする形になる。
    ##
    if @vocabulary.has_key?(@user_input[-1])
      @vocabulary.each do |first_word,array|
        if first_word == @user_input[-1]
          response_data = array.shift
          @vocabulary[first_word] = array #hashの値を更新する
          return response_data
        end
      end
    end
  end

  def muno_check
    csv_load
    making_hash
    #print @vocabulary
    response_data = response
    csv_writer
    return response_data
  end

  def csv_writer
    json_file_path = "#{Rails.root}/public/csvdata/muno_message.json"
    open(json_file_path, 'w') do |io|
      JSON.dump(@vocabulary, io)
    end
  end
 end
end

