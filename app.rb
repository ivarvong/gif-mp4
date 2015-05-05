require 'sinatra'
require 'httparty'
require 'tempfile'
require "rack-cache"

get '/' do
	redirect "/mp4?url=http://bukk.it/wut.gif"
end

get '/mp4' do
	begin
		start_time = Time.now.utc.to_f
		url = params['url']
		puts "Converting #{url}"

		gif_file = Tempfile.new('gif').path + ".gif"
		File.open(gif_file, 'wb') do |f|
			f.write(HTTParty.get(url).body)
		end
		mp4_file = Tempfile.new('mp4').path + ".mp4"

		`ffmpeg -i "#{gif_file}" -pix_fmt yuv420p "#{mp4_file}"`

		headers "Cache-Control" => "public, max-age=300"
		headers "X-Convert-Time" => "#{(Time.now.utc.to_f - start_time).round(2)}"
		content_type "video/mp4"
		File.open(mp4_file, 'rb').read

	rescue
		status_code 500
		content_type "text/plain"
		"Error converting"
	end
end