class CrawlerController < ApplicationController

	def index
		github = Github.new

		github
		.pull_requests
		.list(user: 'rails', repo: 'rails') do |pull_request|
			result = {}
			github.pull_requests.files(
				user: 'rails',
				repo: 'rails',
				number: pull_request['number']
			).each do |file|
				result << [ file['filename'], file['patch'][/\A@@ (.*) @@/, 1], file['blob_url'] ]
			end
			pp result
		end
		render json: { response: result }
	end

end