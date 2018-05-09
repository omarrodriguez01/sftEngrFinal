require "sinatra"
require_relative "authentication.rb"
require 'stripe'
require 'date'
require 'plaid'
require 'json'
require 'openssl'
require 'data_mapper'
require_relative "transactions.rb"
require_relative "user_info.rb"

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

client = Plaid::Client.new(env: :development,
                           client_id: ENV['PLAID_CLIENT_ID'],
                           secret: ENV['PLAID_SECRET'],
                           public_key: ENV['PLAID_PUBLIC_KEY'])

access_token = nil

get "/" do
	erb :index
end

get "/dashboard" do

  
    # purge dead connections
  authenticate!
  @transactions=Trans.all
  @user_info = User_info.all 
  @total = 0

  @goal

  @saved
  @weeklyG
  @budget
  puts" "
  puts current_user.email
  puts " "
  @transactions.each do |trans, x|
    puts trans.email
  if trans.email == current_user.email
   @total = @total + trans.trans_amount 
   puts @total 
   puts trans.trans_amount
   puts " "
  end
  puts @total
  end
  @user_info.each do|info|
    puts info.email
    if info.email == current_user.email
      @goal = info.goal
      @budget = info.weekly_spent
      @weeklyG = info.weekly_goal
      @saved = info.overallsaved

    end

  end
@saved = @saved + (@budget - @total)
@tws = @budget - @total
@ncb = @budget - @weeklyG 

  erb :dashboard



  
end

get "/set_up" do
  erb :set_up
end
get "/set_up2" do
  erb :set_up2

end

post "/create_user_info" do
  user = User_info.new
  user.goal = params["goal"]
  user.weekly_spent = params["weekly_spent"]
  user.weekly_goal = params["weekly_goal"]
  user.email = current_user.email
  user.overallsaved =0
  user.save
  redirect "/set_up2"
end

post '/get_access_token' do

  exchange_token_response = client.item.public_token.exchange(params['public_token'])
  access_token = exchange_token_response['access_token']
  item_id = exchange_token_response['item_id']
  puts "access token: #{access_token}"
  puts "item id: #{item_id}"
  exchange_token_response.to_json
end
get '/accounts' do
  auth_response = client.auth.get(access_token)
  content_type :json
  auth_response.to_json
end

get '/item' do
  item_response = client.item.get(access_token)
  institution_response = client.institutions.get_by_id(item_response['item']['institution_id'])
  content_type :json
  { item: item_response['item'], institution: institution_response['institution'] }.to_json
end

get '/create_public_token' do
  public_token_response = client.item.public_token.exchange(access_token)
  content_type :json
  public_token_response.to_json
end

post '/trans' do
now = Date.today
  thirty_days_ago = (now - 7)
  begin
    transactions_response = client.transactions.get(access_token, thirty_days_ago, now)
  rescue Plaid::ItemError => e
    transactions_response = { error: {error_code: e.error_code, error_message: e.error_message}}
  end
  content_type :json
  hash2 = transactions_response.to_json

  result = JSON.parse(hash2)

  hash_array = result["transactions"]


  hash_array.each do |item|
    trans = Trans.new
    trans.trans_amount = item["amount"]
    trans.trans_category = item["category"][0]
    trans.trans_type = item["category"][1]
    trans.email = current_user.email
    trans.trans_date = item["date"]

    trans.save
  end
  puts now
  redirect "/dashboard"
end

#Stripe Monthly Subscription
post '/charge' do
  @amount = 500

  Stripe::Customer.create(
    :email => params[:email],
    :source  => params[:stripeToken]
  )

  charge = Stripe::Charge.create(
    :amount      => @amount,
    :interval 	 => "month",
    :product => {:name => "Pigdget"},
    :description => 'Sinatra Charge',
    :currency    => 'usd',
    :customer    => customer.id
    #:items => {:plan => "gold"}
  )
  current_user.stripe =true

  erb :charge
end

error Stripe::CardError do
  env['sinatra.error'].message
end

#<Stripe::StripePbject id=pigdget 0x00000a> JSON: 
{
  "id": "Pigdget",
  "object": "subscription",
  "application_fee_percent": 0.5,
  "billing": "charge_automatically",
  "billing_cycle_anchor": 1525463622,
  "cancel_at_period_end": false,
  "created": 1525463622,
  "current_period_end": 1528142022,
  "current_period_start": 1525463622,
  "customer": "cus_CnlVTrpUNhn1W2",
  "items": {
    "object": "list",
    "data": [
      {
        "id": "Pigdget",
        "object": "subscription_item",
        "created": 1525463623,
        "metadata": {
        },
        "plan": {
          "id": "Pigdget",
          "object": "plan",
          "amount": 500,
          "billing_scheme": "per_unit",
          "created": 1506381458,
          "currency": "usd",
          "interval": "month",
          "interval_count": 1,
          "livemode": false,
          "metadata": {
          },
          "name": "Pigdget Exclusive",
          "nickname": "Gold Level",
          "product": "prod_BT1t06tZ3jBCHi",
          "trial_period_days": 30,
          "usage_type": "licensed"
        },
        "quantity": 1,
        "subscription": "sub_CnlVDSfE0MhpFD"
      }
    ],
    "has_more": false,
    "total_count": 1,
    "url": "/v1/subscription_items?subscription=sub_CnlVDSfE0MhpFD"
  }
}



