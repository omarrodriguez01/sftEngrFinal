require 'data_mapper'

if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end

class User_info
    include DataMapper::Resource
    property :id, Serial
    property :email, String
    property :goal, Float
    property :lastLogin, DateTime
    property :weekly_spent, Float
    property :overallsaved, Float
    property :budget, Float
    property :week_saved, Float
    property :weekly_goal, Float
    property :created_at, DateTime
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
User_info.auto_upgrade!