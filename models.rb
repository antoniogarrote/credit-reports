require 'mongoid'
require 'namey'
require 'autoinc'
require 'faker'
require 'mongo'

module RandomGenerators

  def random_int(max)
    ((rand * max * 1000 ) % max).to_i
  end

  def random_score(x = 50)
    ('A'..'D').to_a.shuffle.first
  end

  def random_date
    Faker::Date.between(1.year.ago, Date.today)
  end

  def random_provider
    (rand * 100).to_i % 2 == 0 ? "experian" : "equifax"
  end

end

Mongoid.load!("./mongoid.yml", :development)

## READONLY!!
class CustomerData
  include Mongoid::Document


  field :customer_id, type: Integer
  field :type, type: String
  field :lei, type: String
  field :email, type: String
  field :tax_id, type: String
  field :title, type: String
  field :given_name, type: String
  field :family_name, type: String
  field :gender, type: String
  field :vat_id, type: String
  field :birth_date, type: String
  field :death_date, type: String

end


class CreditReportData

  include Mongoid::Document
  include Mongoid::Autoinc
  extend RandomGenerators

  field :id, type: Integer
  field :customer_id, type: Integer
  field :provider, type: String
  field :date, type: String
  field :score, type: String

  increments :id

  def self.next(customer_id)
    CreditReportData.new(customer_id: customer_id,
                         provider: random_provider,
                         date: random_date,
                         score: random_score)
  end
end

include RandomGenerators

def clean
  CreditReportData.destroy_all
end

def generate
  CustomerData.all.each do |c|
    (0 .. random_int(5)).each do |i|
      CreditReportData.next(c.customer_id).save!
    end
  end
end
