require 'sinatra'
require 'httparty'
require 'tempfile'
require "rack-cache"

get '/' do
	redirect "/mp4?url=http://bukk.it/wut.gif"
end

def convert(gif_file, mp4_file)
	`ffmpeg -f gif -i #{gif_file} #{mp4_file}`
	mp4_file
rescue
	nil
end

def download_gif(url)
	tmp_file = Tempfile.new('gif').path + ".gif"
	File.open(tmp_file, 'wb') do |f|
		f.write(HTTParty.get(url).body)
	end
	tmp_file
end

get '/mp4' do
	start_time = Time.now.utc.to_f
	url = params['url']
	puts "Converting #{url}"

	gif_file = download_gif(url)
	mp4_file = Tempfile.new('mp4').path + ".mp4"

	if convert(gif_file, mp4_file)
		headers "Cache-Control" => "public, max-age=300"
		headers "X-Convert-Time" => "#{(Time.now.utc.to_f - start_time).round(2)}"
		content_type "video/mp4"
		File.open(mp4_file).read
	else
		status_code 500
		content_type "text/plain"
		"Error converting"
	end
	
end