$:.push File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'bundler'
Bundler.setup :default, :development, :example, ENV['RACK_ENV']

require 'sinatra'
require 'omniauth-browserid'
require 'pry'

use Rack::Session::Cookie
use OmniAuth::Strategies::BrowserID

get '/' do
  "<a href='/auth/browser_id'>Auth with BrowserID</a>"
end

post '/auth/browser_id/callback' do
  content_type 'text/plain'
  request.env['omniauth.auth'].to_hash.inspect
end