require 'sinatra'
require 'sinatra/cross_origin'
require 'mongoid'
require './models'

configure do
  enable :cross_origin
end

get '/applicants' do
  if (params[:skip])
    CustomerData
      .skip(params[:skip].to_i)
      .limit(params[:count].to_i)
      .to_json(except: :_id)
  else
    CustomerData.all.to_json(except: :_id)
  end
end

get '/applicants/:applicant_id' do
  begin
    CustomerData
      .where(customer_id: params[:applicant_id].to_i)
      .first
      .to_json(except: :_id)
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end

get '/applicants/:applicant_id/reports' do
  begin
    puts "A"
    reports = CreditReportData.where(customer_id: params[:applicant_id].to_i)
    reports.all.to_json(except: :_id)
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end

get '/applicants/:applicant_id/reports/:id' do
  begin
    puts "B"
    CreditReportData
      .where(customer_id: params[:applicant_id].to_i,
             id: params[:id].to_i)
      .first
      .to_json(except: :_id)
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end

set :port, 4568
