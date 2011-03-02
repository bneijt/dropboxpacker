#!/usr/bin/ruby
require 'sinatra'
require 'erb'
require 'find'
HOSTPATH='/tmp'
FILES = []
Find.find(HOSTPATH) do |p|
    if File.file?(p):
        FILES.push(p)
    end
end
get '/' do
    @files = FILES
    erb :index
end

