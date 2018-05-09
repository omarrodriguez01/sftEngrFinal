require 'data_mapper'

if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end

class Trans
    include DataMapper::Resource
    property :id, Serial

    property :email,String
    property :trans_amount, Float
    property :trans_type, String
    property :trans_category, String
    property :trans_date, Date
    property :created_at, DateTime
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the post table
Trans.auto_upgrade!