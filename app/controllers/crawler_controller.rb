class CrawlerController < ApplicationController

	def index
		pp Github.repos.list(user: 'rails').body
		pp Github.repos.list(user: 'rails').body.count
		render json:  { 'repos' => '' }
	end

end