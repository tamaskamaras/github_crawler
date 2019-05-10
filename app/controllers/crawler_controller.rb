class CrawlerController < ApplicationController

	def index
		result = ApiCrawler.new('rails', 'rails').filtered_pull_request
		render json: { response: result }
	end

end