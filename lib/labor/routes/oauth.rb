require "sinatra/base"
require 'http'
require_relative '../models/user'
require_relative '../errors'

module Labor
	class App < Sinatra::Base

		get '/oauth/resource/user' do 
		  query_message = ['redirect_uri', 'code', 'client_id', 'client_secret']
		  	.map { |key| "#{key}=#{params[key]}" }
		  	.compact
		  	.push('grant_type=authorization_code')
		  	.join('&')
		  host = params['host'] 


		  result = HTTP.post("#{host}/oauth/token?#{query_message}")
		  if result.code == 200
		  	result = JSON.parse(result) 
		  	result = HTTP.auth("bearer #{result['access_token']}").get("#{host}/oauth/user")
		  	if result.code == 200
		  		user_hash = result.parse

		  		# 每次登录，更新用户信息
		  		user = User.find_or_create_by(nickname: user_hash['nickname']) 
		  		['sub', 'email', 'phone_number', 'picture'].each do |key|
		  			user.send("#{key}=", user_hash[key]) 
		  		end
	  			user.save 

		  		labor_response user
		  	else 
		  		halt result.code, labor_error("Fail to get user with error #{result.to_s}")
		  	end
		  else 
		  	halt result.code, labor_error("Fail to get access_token with query_message #{query_message} host #{host} error #{result.to_s}")
		  end
		end

# 暂时不需要用 refresh_token
# 刷新 access_token
# - client_id:         应用在 o2 上的 id
# - client_secret:     应用在 yoyo 街面上请求到的 client_secret
# - grant_type:        固定 refresh_token
# - refresh_token      前面有效的 refresh_token
	end
end