require 'sinatra'
require 'sinatra/reloader'
require 'json'
require "erb"

# htmlをエスケープするモジュールを読み込む
include ERB::Util

# put/deleteフォームを、それらをサポートしないブラウザで使えるように_methodのおまじないを使えるようにする。
enable :method_override 

# errorや404を捕捉するため 環境設定を変更。
# ただし、productionだとsinatra reloaderは機能しなくなる
set :environment => :production


get '/' do
  @title = "メモ帳"
  erb :index
end

get '/add_new_memo' do
  erb :add_new_memo
end

post '/post_complete' do
  @title = html_escape(params[:title])
  @memo_text = html_escape(params[:memo_text])
  erb :post_complete
end

get '/memo/:memo_uuid' do |memo_uuid|
  hash = {}
  File.open("data/#{memo_uuid}.json") do |f|
  hash = JSON.load(f)
  end
  @hash = hash
  erb :memo_detail
end

delete '/memo/:memo_uuid/delete_complete' do |memo_uuid|
  @memo_uuid = memo_uuid
  erb :delete_complete
end

patch '/memo/:memo_uuid/edit_complete' do |memo_uuid|
  @memo_uuid = memo_uuid
  @title = html_escape(params[:title])
  @memo_text = html_escape(params[:memo_text])
  erb :edit_complete
end

get '/memo/:memo_uuid/edit' do |memo_uuid|
  hash = {}
  File.open("data/#{memo_uuid}.json") do |f|
  hash = JSON.load(f)
  end
  @hash = hash
  erb :memo_edit
end

not_found do
  'ファイルが存在しません'
end

error do
  'エラーが発生しました。 - ' + env['sinatra.error'].message
end