class ApiCrawler

	attr_reader :user, :repo, :github_client

	def initialize attributes
		@user 				 = attributes[:user]
		@repo 				 = attributes[:repo]
		@github_client = Github.new(basic_auth: "#{attributes[:login]}:#{attributes[:password]}")
	end

	def filtered_pull_request
		result = {}
		github_client
		.pull_requests
		.list(user: user, repo: repo) do |pull_request|
			file_attributes = {}
			github_client
			.pull_requests
			.files(user: user, repo: repo, number: pull_request['number']).each do |file|
				unless file_attributes[ file['filename'] ]
				  file_attributes[ file['filename'] ] = {
				  	blob_url: file['blob_url'],
				  	patches:  [ file['patch'][/\A@@ (.*) @@/, 1] ], 
				  }
				else
				  file_attributes[ file['filename'] ][:patches] << file['patch'][/\A@@ (.*) @@/, 1]
				end
			end
			if file_urls = redundant_file_urls(file_attributes)
				result.merge({ [ pull_request['url'] ] => file_urls })
			end
		end
		result
	end

	def redundant_file_urls file_attributes
		result = []
		file_attributes.each do |filename, attributes|
			if (line_numbers = attributes[:patches]).length > 1
				line_numbers.each do |lineno|
					lineno[/\A-(.*) /, 1].split(',')
				end
			end
		end
		result
	end

end
