require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require './models.rb'
require 'sinatra/base'
require 'net/http'
require 'rest-client'
require 'google/apis/sheets_v4'

enable :sessions

get '/' do 
    session[:result] = 0
    session[:question] = 0
    erb :index
end

post '/start_quiz' do
  number = rand(Mentor.all.length) + 1
  redirect "/question/#{number}"
end

get '/question/:id' do
   @question = Mentor.find_by(id: params[:id])
   erb :question
end

post '/question/check/:id' do
    question = Mentor.find_by(id: params[:id])
    answer = question.answer
    select_answer = params[:select_answer].to_i
    session[:question] = session[:question] + 1
    if answer == select_answer
        session[:result] = session[:result] + 1
    end
    if session[:question] == 5
        redirect '/result'
    else
        number = rand(Mentor.all.length) + 1
        redirect "/question/#{number}"
    end
end

get '/result' do
    erb :result
end

get '/remake_mentors_table' do
  credential_file = './MyProject-e3ddd3ab5bd6.json'
  
  authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(credential_file),
      scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS
  )  
  authorizer.fetch_access_token!
  
  s_service = Google::Apis::SheetsV4::SheetsService.new
  s_service.authorization = authorizer
  
    for num in 2..20
      num = num.to_s
      data = s_service.batch_get_spreadsheet_values('1zDTlaGRAP8Lw1nUJUnr7QgJbHuzTuEZ3SKFM0_E53FM', ranges: 'A' + num + ':E' + num).value_ranges.first.values
      unless data.blank?  
        Mentor.create(
          picture: data[0][0],
          choice1: data[0][1],
          choice2: data[0][2],
          choice3: data[0][3],
          answer: data[0][4]
          )
      else
        break
      end
    end
end