#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

get '/' do
	erb "Hello! </a>"			
end

get '/lasttopics' do
  "Hello World"
end

get '/newpost' do
  erb :newpost
end