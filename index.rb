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
      .map { |customer|
        {:customer_id => customer[:customer_id], :email => customer[:email]}
      }.to_json
  else
    CustomerData.all.map { |customer|
      {:customer_id => customer[:customer_id], :email => customer[:email]}
    }.to_json
  end
end

get '/applicants/:applicant_id' do
  begin
    customer = CustomerData.where(customer_id: params[:applicant_id].to_i).first
    {:customer_id => customer[:customer_id], :email => customer[:email]}.to_json
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end

get '/applicants/:applicant_id/reports' do
  begin
    if (params[:skip])
      puts "SKIPPING"
      reports = CreditReportData
                  .where(customer_id: params[:applicant_id].to_i)
                  .skip(params[:skip].to_i)
                  .limit(params[:count].to_i)
      reports.all.to_json(except: :_id)
    else
      puts "ALL"
      reports = CreditReportData.where(customer_id: params[:applicant_id].to_i)
      reports.all.to_json(except: :_id)
    end
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end

get '/applicants/:applicant_id/reports/:id' do
  begin
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
