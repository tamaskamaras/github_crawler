class CrawlerController < ApplicationController

	def index
		github = Github.new
		# files = github.pull_requests.files(user: 'rails', repo: 'rails', number: 36200)

		github
		.pull_requests
		.list(user: 'rails', repo: 'rails') do |pull_request|
			result = []
			# commits = github.pull_requests.commits(user: 'rails', repo: 'rails', number: pull_request['number'])
			github.pull_requests.files(
				user: 'rails',
				repo: 'rails',
				number: pull_request['number']
			).each do |file|
				result << [ file['filename'], file['patch'][/\A@@ (.*) @@/, 1] ]
			end
			pp result
		end
		render json: { response: result }
	end

end