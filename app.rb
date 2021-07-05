require 'sinatra'
require 'sinatra/reloader'
require 'json'
require "erb"
require 'securerandom'

# htmlをエスケープするモジュールを読み込む
include ERB::Util

# put/deleteフォームを、それらをサポートしないブラウザで使えるように_methodのおまじないを使えるようにする。
enable :method_override 

# errorや404を捕捉するため 環境設定を変更。
# ただし、productionだとsinatra reloaderは機能しなくなる
# set :environment => :production


get '/' do
  @title = pagetitle('一覧')
  erb :index
end

get '/add_new_memo' do
  @title = pagetitle('新規作成')
  erb :add_new_memo
end

post '/post_complete' do
  # title = html_escape(params[:title])
  # memo_text = html_escape(params[:memo_text])

  hash = {
  memo_uuid: "#{SecureRandom.uuid}",
  title: "#{html_escape(params[:title])}",
  text: "#{html_escape(params[:memo_text])}"
  }
  hash[:title] = "タイトルなし" if hash[:title].empty? 

  File.open("data/#{hash[:memo_uuid]}.json","w") {|file| 
    file.puts(JSON.generate(hash))
  }

  redirect '/'
end

get '/memo/:memo_uuid' do |memo_uuid|
  @hash = {}
  File.open("data/#{memo_uuid}.json") do |f|
    @hash = JSON.load(f)
  end
  @title = pagetitle(@hash["title"])
  erb :memo_detail
end

delete '/memo/:memo_uuid/delete_complete' do |memo_uuid|
  File.delete("data/#{memo_uuid}.json")
  
  redirect '/'
end

patch '/memo/:memo_uuid/edit_complete' do |memo_uuid|
  hash = {
  memo_uuid: "#{memo_uuid}",
  title: "#{html_escape(params[:title])}",
  text: "#{html_escape(params[:memo_text])}"
  }
  hash[:title] = "タイトルなし" if hash[:title].empty?

  File.open("data/#{hash[:memo_uuid]}.json","w") {|file| 
    file.puts(JSON.generate(hash))
  }

  redirect "/memo/#{hash[:memo_uuid]}"
end

get '/memo/:memo_uuid/edit' do |memo_uuid|
  @title = pagetitle('編集')
  @hash = {}
  File.open("data/#{memo_uuid}.json") do |f|
    @hash = JSON.load(f)
  end
  erb :memo_edit
end

not_found do
  @title = pagetitle('ファイルが存在しません')
  'ファイルが存在しません'
end

error do
  @title = pagetitle('エラー')
  'エラーが発生しました。 - ' + env['sinatra.error'].message
end

def pagetitle(title)
  return "#{title} / メモ帳"
end