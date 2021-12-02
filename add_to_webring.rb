require "active_record"

class Website < ActiveRecord::Base
end

puts "Enter the name of the website:"
name = gets.chomp

puts "Enter the website domain name:"
domain_name = gets.chomp

puts "Enter a description for the website:"
description = gets.chomp

puts "Enter the name of the generator used by the website (i.e. Jekyll, Hugo):"
generator = gets.chomp

puts "Enter a link to the generator used by the website (optional):"
generator_url = gets.chomp

Website.establish_connection(
    :adapter => "sqlite3",
    :database => "websites.db"
)

current_time = Time.now.to_s

Website.create(
    :name => name,
    :domain_name => domain_name,
    :description => description,
    :generator => generator,
    :generator_url => generator_url,
    :joined_date => current_time
)