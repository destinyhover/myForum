#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

configure do 	
	$db = SQLite3::Database.new 'forumdb.db'
	$db.execute'create table if not exists "Content" (id Integer, content Text, time Date, Primary Key("id" Autoincrement));'
	$db.execute'create table if not exists "Users" (id Integer, Username Text, post_id Integer, Primary Key("id" Autoincrement));'
	$db.execute'create table if not exists "Comments" (id Integer, content Text, post_id Integer, created_date Date, Primary Key("id" Autoincrement));'
	$db.results_as_hash = true

	# $db.close
end
# def get_db
#   @db = SQLite3::Database.new 'forumdb.db'
#   @db.results_as_hash = true
#   return @db
# end

get '/lasttopics' do
		@results = $db.execute 'select * from Content order by id desc'	
	erb :lasttopics			
end

get '/' do
  erb "<h1>My simple forum here</h1>"

end

get '/newpost' do
  erb :newpost
end

post '/newpost' do
	# получаем переменную из post-запроса
	@username =params[:username]
	@content = params[:content]
	if @content.strip.length <= 5 or @username.length <= 1
		@error = 'Enter right'
		return erb :newpost
	end

	# сохранение данных в БД

	$db.execute 'insert into Content (content, time) values (?,datetime())', [@content]
	post_id = $db.last_insert_row_id
	$db.execute 'insert into Users (Username, post_id) values (?,?)', [@username, post_id]

	# перенаправление на главную страницу

	redirect to '/'
end


get '/details/:post_id' do

	# получаем переменную из url'a
	post_id = params[:post_id]

	# получаем список постов
	# (у нас будет только один пост)
	results = $db.execute 'select * from Content where id = ?', [post_id]
	name1 = $db.execute 'select Username from Users where post_id = ?', [post_id]		
	@name = name1[0]
	# выбираем этот один пост в переменную @row
	@row = results[0]

	# выбираем комментарии для нашего поста
	@comments = $db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	# возвращаем представление details.erb
	erb :details
end
post '/details/:post_id' do
	post_id=params[:post_id]
	content=params[:content]
	$db.execute 'insert into Comments (content, post_id, created_date) values (?,?, datetime())', [content, post_id]
	redirect to ('/details/' + post_id)
end