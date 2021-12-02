require "active_record"
require "nokogiri"
require "net/http"
require "logger"

# initialize logs

logger = Logger.new("logs/validate_entries.log")
logger.level = Logger::INFO

# connect to database
class Website < ActiveRecord::Base
end

Website.establish_connection(
    :adapter => "sqlite3",
    :database => "./webring.db"
)

all_websites = Website.all

for w in all_websites
    check_website_request = Net::HTTP.get_response("https://" + w.domain_name)

    if check_website_request.code == "404"
        logger.info("Website " + w.domain_name + " is not available. Removing from database.")
        Website.delete(w.id)
    end

    parsed_website = Nokogiri::HTML(check_website_request.body)

    webring_url_found = false

    for url in parsed_website.css("a")
        if url.attribute("href").nil?
            next
        end

        if url.attribute("href").value == "https://static-webring.jamesg.blog/previous" || \
            url.attribute("href").value == "https://static-webring.jamesg.blog/next"
            webring_url_found = true
        end
    end

    if webring_url_found == false
        logger.info("Website " + w.domain_name + " no longer includes a link to the webring. Removing from database.")
        Website.delete(w.id)
    end
end