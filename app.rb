#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

configure do 	
	$db = SQLite3::Database.new 'forumdb.db'
	$db.execute'create table if not exists "Content" (id Integer, content Text, time Date, Primary Key("id" Autoincrement));'
	$db.execute'create table if not exists "Users" (id Integer, Username Text, post_id Integer, Primary Key("id" Autoincrement));'
$db.results_as_hash = true

	# $db.close
end
# def get_db
#   @db = SQLite3::Database.new 'forumdb.db'
#   @db.results_as_hash = true
#   return @db
# end

get '/' do
		@results = $db.execute 'select * from Content order by id desc'	
	erb :index			
end

get '/lasttopics' do
  "Hello World"
end

get '/newpost' do
  erb :newpost
end

post '/newpost' do
	# получаем переменную из post-запроса
	@username =params[:username]
	@content = params[:content]
	if @content.strip.length <= 5 && @username.length <= 1
		@error = 'Enter right'
		return erb :newpost
	end

	# сохранение данных в БД

	$db.execute 'insert into Content (content, time) values (?,datetime())', [@content]
	post_id = $db.last_insert_row_id
	$db.execute 'insert into Users (Username, post_id) values (?,?)', [@content, post_id]

	# перенаправление на главную страницу

	redirect to '/'
end


