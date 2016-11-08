#! ruby -Ks
# ───── for　ruby 1.9 ─────
# ───── 2012.03.11 coded by 心如

class Shiritori
    attr_accessor :fname, :data, :aite, :henji, :used, :backup
    
    def initialize f
        @fname = f
        @data = readFromFile(fname)
        @aite = nil
        @henji = "しりとり"
        @used = {}
        @backup = cloneData(@data)
    end
    
    # ファイルのデータを読み込む
    def readFromFile f
        data = {}
        begin
            file = File.open(f)
            while(str = file.gets)
                str = str.chomp
                arr = str.split(",")
                key = arr[0]
                arr.shift
                data.store key, arr
            end
        rescue Exception => e
            puts "データファイルのオープンに失敗しました。ファイルが存在しないようです。(" + e.message + ")"
        ensure
            file.close if file != nil
        end
        return data
    end
    
    # ファイルにデータを書き出す
    def saveToFile f, data
        begin
            file = File.open( f, "w")
            file.flock(File::LOCK_EX)
            ka = []
            data.each do |key, arr|
                ka << key
            end
            (ka.sort).each do |key|
                arr = data[key]
                arr.sort!
                file.puts key + "," + arr.join(",")
            end
        rescue Exception => e
            puts "何らかの原因でデータの保存に失敗しました。(" + e.message + ")"
            return
        ensure
            if file != nil
                file.flock(File::LOCK_UN)
                file.close
            end
        end
    end
    
    # 最後の文字を返す
    def getLastChar str
        komoji = {"ぁ"=>"あ","ぃ"=>"い","ぅ"=>"う","ぇ"=>"え","ぉ"=>"お","ゃ"=>"や","ゅ"=>"ゆ","ょ"=>"よ","ゎ"=>"わ"}
        last = str[-1]
        last = str[-2] if last == "ー"
        last = komoji[last] if komoji.has_key?(last)
        return last
    end
    
    # データハッシュの複製
    def cloneData h1
        h2 = {}
        h1.each do |key, obj|
            h2.store key, obj.dup
        end
        return h2
    end
    
    # デバッグ用出力メソッド
    def printData d
        ka = []
        d.each do |key,arr|
            ka << key
        end
        ka.sort!
        (ka.size).times do |n|
            key = ka[n]
            arr = d[key]
            puts key + ": " + arr.join(",")
        end
    end
    
    # しりとり本体
    def shiritori
        puts "わたし：" + @henji
        mytop = @henji[0]
        mylast = getLastChar(@henji)
        puts mylast
        # 使った単語を使用済みハッシュに登録する
        @used.store @henji,"わたし"
        @data[mytop].delete @henji if @data.has_key?(mytop)
        # 相手の答えを得る
        print "あなた："
        @aite = gets.chomp
        top = @aite[0]
        # 開始文字のチェック
        if mylast != top then
            puts "先頭の文字が異なります、あなたの負けです。"
            return false
        end
        # 最後の文字を取得し、小文字なら大文字に直す
        last = getLastChar(@aite)
        puts last
        @data[top].delete @aite if @data.has_key?(top)
        # "ん"で終わったときの処理
        if last == "ん" then
            puts "「ん」で終わっています、あなたの負けです。"
            return false
        end
        # 既に使われている単語かチェックし、
        # 未使用であれば使用済みに登録
        if @used.has_key?(@aite) then
            puts "それは前に、#{@used[@aite]}が使っています。"
            puts "あなたの負けです。"
            return false
        else
            @used.store @aite,"あなた"
        end
        # まだ知らない単語ならバックアップのハッシュに登録
        if @backup.has_key?(top) then
            flg = false
            @backup[top].each do |obj|
                flg = true if @aite == obj
            end
            @backup[top].push @aite if flg == false
        else
            @backup.store top,[@aite]
        end
        # 次の答えを準備
        # 答える単語がなければ負け
        if @data.has_key?(last) == false or @data[last].length == 0
            3.times do
                print "・"
                sleep 0.5
            end
            puts "思いつきません、あなたの勝ちです。"
            return false
        end
        num = rand(@data[last].length)
        @henji = @data[last][num]
        return true
    end
    
    # しりとりループ
    def playloop
        loop do
            begin
                while(shiritori)
                end
            rescue Exception => e
                puts "プログラムの実行時に問題が発生しました。(" + e.message + ")"
                return
            end
            
            # 再プレイの処理
            print "\nもう一度やりますか（はい/いいえ)？ "
            break if gets.chomp == "いいえ"
            puts
            @data = cloneData(@backup)
            @used = {}
            @henji = "しりとり"
        end
    end
    
    # 終了処理
    def dispose
        puts "\nわたし：バイバイ！"
        saveToFile(@fname,@backup)
        puts "program end."
    end
end

# メインプログラム
game = Shiritori.new("data.txt")
game.playloop
game.dispose