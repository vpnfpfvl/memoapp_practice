# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'erb'
require 'securerandom'

# put/deleteフォームを、それらをサポートしないブラウザで使えるように_methodのおまじないを使えるようにする。
enable :method_override

# errorや404を捕捉するため 環境設定を変更。
# ただし、productionだとsinatra reloaderは機能しなくなる
set environment: :production

# htmlをエスケープするモジュールを読み込む
include ERB::Util

get '/' do
  @title = pagetitle('一覧')
  erb :index
end

get '/add_new_memo' do
  @title = pagetitle('新規作成')
  erb :add_new_memo
end

post '/post_complete' do
  hash = make_new_hash(
    SecureRandom.uuid.to_s,
    html_escape(params[:title]).to_s,
    html_escape(params[:memo_text]).to_s
  )
  write_jsonfile(hash)
  redirect '/'
end

get '/memo/:memo_uuid' do |memo_uuid|
  @hash = convert_jsonfile_to_hash("data/#{memo_uuid}.json")
  @title = pagetitle(@hash['title'])
  erb :memo_detail
end

delete '/memo/:memo_uuid/delete_complete' do |memo_uuid|
  File.delete("data/#{memo_uuid}.json")
  redirect '/'
end

patch '/memo/:memo_uuid/edit_complete' do |memo_uuid|
  hash = make_new_hash(
    memo_uuid.to_s,
    html_escape(params[:title]).to_s,
    html_escape(params[:memo_text]).to_s
  )
  write_jsonfile(hash)
  redirect "/memo/#{hash[:memo_uuid]}"
end

get '/memo/:memo_uuid/edit' do |memo_uuid|
  @title = pagetitle('編集')
  @hash = convert_jsonfile_to_hash("data/#{memo_uuid}.json")
  erb :memo_edit
end

not_found do
  @title = pagetitle('ファイルが存在しません')
  'ファイルが存在しません'
end

error do
  @title = pagetitle('エラー')
  puts "エラーが発生しました。 -  #{env['sinatra.error'].message}"
end

def pagetitle(title)
  "#{title} / メモ帳"
end

def convert_jsonfile_to_hash(source)
  File.open(source) do |f|
    JSON.parse(f.read)
  end
end

def make_new_hash(uuid, title, text)
  hash = { memo_uuid: uuid, title: title, text: text }
  hash[:title] = 'タイトルなし' if hash[:title].empty?
end

def write_jsonfile(hash)
  File.open("data/#{hash[:memo_uuid]}.json", 'w') do |file|
    file.puts(JSON.generate(hash))
  end
end
