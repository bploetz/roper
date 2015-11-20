# roper

Rails OAuth2 Provider. Fully implements the [OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749) with support for JWT extension grants.

## Installation

Add the following dependency to your Rails application's `Gemfile` file and run `bundle install`:

    gem 'roper'


## Configuration

Mount the roper engine by adding the following to your `config/routes.rb` file:

```ruby
mount Roper::Engine, at: "/oauth"
```

All roper provided endpoints will be scoped under the `/oauth` path
