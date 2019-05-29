class ApiCrawler

	attr_reader :user, :repo, :github_client

	def initialize attributes
		@user 				 = attributes[:user]
		@repo 				 = attributes[:repo]
		@github_client = Github.new(basic_auth: "#{attributes[:login]}:#{attributes[:password]}")
	end

	def filtered_pull_request
		result = {}
		pull_requests do |pull_request|
			file_attributes = {}
      pull_request_files(pull_request['number']) do |file|
				file_name = file['filename']
        (file_attributes[file_name] || file_attributes[file_name] = {
          blob_url: file['blob_url'],
          patches:  []
        })[:patches] << file['patch'][/\A@@ (.*) @@/, 1]
			end
			if file_urls = redundant_file_urls(file_attributes)
				result.merge({ [ pull_request['url'] ] => file_urls })
			end
		end
		result
	end

  def pull_requests
    github_client.pull_requests.list(user: user, repo: repo) do |pull_request|
      yield(pull_request)
    end
  end

  def pull_request_files pull_request_number
    github_client.pull_requests.files(
      user:   user,
      repo:   repo,
      number: pull_request_number
    ).each do |file|
      yield(file)
    end
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
