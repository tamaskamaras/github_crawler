# GitHub Crawler

GitHub Crawler is a simple web application that provides direct access to the official GitHub Api. It utilizes the built-in endpoint methods specified by [GitHub Developer REST API](https://developer.github.com/v3/). The primary feature of GitHub Crawler is *looping through pull requests*. Developer team leaders, scrum masters, project managers often face the problem that within a pull request one particular line of code in a file appears in multiple commits. GitHub Crawler filters this pattern and returns the URL pointing to the respective pull request and to the concerning file(s).

## Usage

GitHub Crawler is a Ruby on Rails application so you only need to [Clone](https://github.com/tamaskamaras/github_crawler.git) this project into your RoR environment and

```sh
$ rails s
```

In order to get the filtered pull requests (containing the redundancy described above) you only need to send a GET request to the root routing of the application and specify in the params that which user's which repo would you like to crawl.

```sh
http://localhost:3000/?user=rails;repo=rails
```

## Authentication

For public repos GitHub allows unauthenticated queries but you can easily run into the rate limit problem that can prevent you to get the required data you need. GitHub Crawler is flexible in terms of authentication (it is not mandatory to provide credentials) but it is highly recommended to do so. You can easily get around the rate limit problem by complementing the above-described GET request with two more keys:
Your GitHub

- login and
- password

```sh
http://localhost:3000/?user=rails;repo=rails;login=LoginName;password=YourSuperSecretPassword
```

These sensitive user data are not stored in the application but directly forwarded to the GitHub Api!

## Result

Upon the correctly created request, you will get the response in `Json` format that you can use further for your own purposes. This `Json` under 'redundancy' key contains the list of the URL-s pointing to the respective pull requests in the form of key-value pairs where the *key* is the _pull request url_ and the *value* is an _Array of links_ to the particular files within the pull request.

## Technology

Thanks to GitHub a fully documented Api is available for us via which we can query a wide range of data for further use. If it would not be enough Ruby developer [Piotr Murach](https://github.com/piotrmurach) created a faithful interface for the above mentioned GitHub Api in the form of a [Ruby gem](https://github.com/piotrmurach/github) that supports all the api methods of the official GitHub Api.

GitHub Crawler is based on this gem.

## Development

Currently, GitHub Crawler provides filtering only for file-row redundancy in pull requests but it is intended to expand its capabilities in the near future.

## Licence

GitHub Crawler is released under [MIT License](https://opensource.org/licenses/MIT)
