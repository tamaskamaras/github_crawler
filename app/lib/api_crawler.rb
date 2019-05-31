class ApiCrawler

  include ResponseProcessor

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
        file_path = file['filepath']
        (file_attributes[file_path] || file_attributes[file_path] = {
          blob_url: file['blob_url'],
          line_ranges:  []
        })[:line_ranges].concat( patchs_to_ranges( file['patch'] ) )
      end
      if ( file_urls = redundant_file_urls(file_attributes) ).present?
        result.merge!({ pull_request['html_url'] => file_urls })
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

end
