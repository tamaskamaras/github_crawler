class CrawlerController < ApplicationController

	def index
		github = Github.new
		# files = github.pull_requests.files(user: 'rails', repo: 'rails', number: 36200)

		result = []
		github
		.pull_requests
		.list(user: 'rails', repo: 'rails') do |pull_request|
			result << github.pull_requests.files(
				user: 'rails',
				repo: 'rails',
				number: pull_request['number']
				)
		end
		render json: { response: result }
	end

end