require_relative './lib/labor'

map '/' do 
	run Labor::App
end

map '/sidekiq' do 
	run Sidekiq::Web
end
