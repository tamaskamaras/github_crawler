class PullRequestCrawler

	attr_reader user, repo

	def initializer user, repo
		@user = user
		@repo = repo
	end

	def pull_request_files
		github = Github.new

		github
		.pull_requests
		.list(user: user, repo: repo) do |pull_request|
			result = {}
			# commits = github.pull_requests.commits(user: 'rails', repo: 'rails', number: pull_request['number'])
			github.pull_requests.files(
				user: user,
				repo: repo,
				number: pull_request['number']
			).each do |file|
				result << [ file['filename'], file['patch'][/\A@@ (.*) @@/, 1], file['blob_url'] ]
			end
			pp result
		end
	end

end