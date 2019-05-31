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

  def patchs_to_ranges patches
    patches.split(%r{@@ -}).map do |patch|
      if raw_range = patch[/\A\d+,\d+/]&.split(',')
        Range.new(
          (start = raw_range[0].to_i),
          start + raw_range[1].to_i
        )
      end
    end.compact
  end

  def redundant_file_urls file_attributes
    file_attributes.inject([]) do |file_urls, (file_path, attributes)|
      if (ranges = attributes[:line_ranges]).length > 1 && overlap_ranges(ranges)
        file_urls << attributes[:blob_url]
      else
        file_urls
      end
    end
  end

  def overlap_ranges ranges
    overlaping = false
    ranges.each_with_index do |comparing_range, comparing_index|
      ranges.each_with_index do |compared_range, compared_index|
        overlaping = overlaping || (
          comparing_index != compared_index &&
          comparing_range.size > 1 &&
          comparing_range.overlaps?(compared_range)
        )
      end
    end
    overlaping
  end

end
