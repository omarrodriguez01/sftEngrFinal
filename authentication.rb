require 'sinatra'
require_relative "user.rb"

enable :sessions

get "/login" do
	erb :"authentication/login"
end


post "/process_login" do
	email = params[:email]
	password = params[:password]

	user = User.first(email: email.downcase)

	if(user && user.login(password))
		session[:user_id] = user.id
		redirect "/dashboard"
	else
		erb :"authentication/invalid_login"
	end
end

get "/logout" do
	session[:user_id] = nil
	redirect "/"
end

get "/sign_up" do
	erb :"authentication/sign_up"
end


post "/register" do
	email = params[:email]
	password = params[:password]

	u = User.new
	if(User.first(email:params["email"]))
		return "This email is already taken"
	end
	u.email = email.downcase
	u.password =  password
	u.stripe = false
	u.save

	session[:user_id] = u.id

	redirect "/set_up"

end

#This method will return the user object of the currently signed in user
#Returns nil if not signed in
def current_user
	if(session[:user_id])
		u = User.first(id: session[:user_id])
		return u
	else
		return nil
	end
end

#if the user is not signed in, will redirect to login page
def authenticate!
	if !current_user
		redirect "/login"
	end
end

#Monthly payments
post "/subscribe" do
	email = params[:email]
	password = params[:password]

	user = User.first(email: email.downcase)

	if(user && user.login(password))
		session[:user_id] = user.id
		erb :"authentication/successful_subscribe"
	else
		erb :"authentication/invalid_login"
	end
end

get "/monthly_up" do
	erb :"authentication/monthly_subscription"
end


get "/cancel_sub" do
	erb :"authentication/cancel_subscription"
end

get "/cancel_subforsure" do
	erb :"authentication/forsure_cancelsub"
end

post "/cancel" do
	email = params[:email]
	password = params[:password]

	user = User.first(email: email.downcase)

	if(user && user.login(password))
		session[:user_id] = user.id
		erb :"authentication/successful_unsubscribe"
	else
		erb :"authentication/invalid_login"
	end
 
end

