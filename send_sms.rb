# Download the twilio-ruby library from twilio.com/docs/libraries/ruby
require 'rubygems'
require 'twilio-ruby'


def sendMessage50

	account_sid = ENV['ACCOUNT_SID']
	auth_token = ENV['AUTH_TOKEN']
	client = Twilio::REST::Client.new account_sid, auth_token

	from = '+1000000' # Your Twilio number
	to = '+100000' # Your mobile phone number

	client.messages.create(
	from: from,
	to: to,
	body: "You already spend 50 percent of your weekly budget")

end

def sendMessage75

	account_sid = ENV['ACCOUNT_SID']
	auth_token = ENV['AUTH_TOKEN']
	client = Twilio::REST::Client.new account_sid, auth_token

	from = '+100000' # Your Twilio number
	to = '+100000' # Your mobile phone number

	client.messages.create(
	from: from,
	to: to,
	body: "You already spend 75 percent of your weekly budget")

end


def sendMessage100

	account_sid = ENV['ACCOUNT_SID']
	auth_token = ENV['AUTH_TOKEN']
	client = Twilio::REST::Client.new account_sid, auth_token

	from = '+100000' # Your Twilio number
	to = '+10000' # Your mobile phone number

	client.messages.create(
	from: from,
	to: to,
	body: "You already spend 100 percent of your weekly budget")

end


def alert (weeklyBud, spent)
 	fiftyPercent = weeklyBud * 0.5
 	sevetyFivePercent = weeklyBud * 0.75

 	if(spent == fiftyPercent)
 		sendMessage50
 	elsif(spent == sevetyFivePercent)
 		sendMessage75
 	elsif(spent >= weeklyBud)
 		sendMessage100
 	end

end



