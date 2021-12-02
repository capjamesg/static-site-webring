require "active_record"
require "sinatra"
require "erb"

class App < Sinatra::Application
	class Website < ActiveRecord::Base
	end

	get "/" do
		template = File.open("templates/index.html").read

		Website.establish_connection(
			:adapter => "sqlite3",
			:database => "./webring.db"
		)

		@websites = Website.all

		@colors = ["#DAA520", "#F0FFF0", "#FFFACD", "#90EE90", "#FAF0E6", "#B0C4DE", "FFF0F5"]

		return ERB.new(template).result(binding)
	end

	def return_website(referrer, request_type)
		Website.establish_connection(
			:adapter => "sqlite3",
			:database => "./webring.db"
		)
		@random_site = Website.all.sample

		if referrer.nil?
			return redirect "https://" + @random_site.domain_name
		end

		@check_if_in_db = Website.where(:domain_name => referrer).first

		if check_if_in_db.nil?
			return redirect "https://" + @random_site.domain_name
		end

		if request_type == "previous"
			@site_to_send_visitor_to = Website.where(:id => @check_if_in_db.id + 1).first
		elsif request_type == "next"
			@site_to_send_visitor_to = Website.where(:id => @check_if_in_db.id - 1).first
		end

		if site_to_send_visitor_to.nil?
			return redirect "https://" + @random_site.domain_name
		end

		return redirect @site_to_send_visitor_to.domain_name
	end

	get "/previous" do
		referrer = request.referrer

		return return_website(referrer, "previous")
	end

	get "/next" do
		referrer = request.referrer

		return return_website(referrer, "next")
	end

	get "/static/webring.css" do
		content_type "text/css"
		return File.read("static/webring.css")
	end

	not_found do
		status 404
		template = File.read("templates/error.html")

		@error_type = 404

		ERB.new(template).result(binding)
	end

	error 500 do
		status 500
		template = File.read("templates/error.html")

		@error_type = 500

		ERB.new(template).result(binding)
	end
end