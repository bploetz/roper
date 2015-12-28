# roper

Rails OAuth2 Provider. Implements all protocol flows defined in the [OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749), as well as support for the following extension grants:

- [JSON Web Tokens (JWT)](https://tools.ietf.org/html/rfc7523)

## Installation

Add the following dependency to your Rails application's `Gemfile` file and run `bundle install`:

    gem 'roper'


## Configuration

Run the following generator to install roper configuration files into your application.

```
bundle exec rails generate roper:install
```

This will copy the following files into your application:

`config/initializers/roper.rb` - Initializer where you configure various features in roper
`config/locales/roper.en.yml` - Locale file used by the [authorization request](https://tools.ietf.org/html/rfc6749#section-4.1.1) view

Mount the roper engine by adding the following to your `config/routes.rb` file:

```ruby
mount Roper::Engine, at: "/oauth"
```

All roper provided endpoints will be scoped under the `/oauth` path.


### ORM Configuration

Roper supports persisting data to a relational database via ActiveRecord, or to MongoDB via [Mongoid](https://docs.mongodb.org/ecosystem/tutorial/ruby-mongoid-tutorial/#ruby-mongoid-tutorial).

#### ActiveRecord

To use a relational database via ActiveRecord, set the `orm` configuration value to `:active_record` in `config/initializers/roper.rb`:

```ruby
Roper.configure do |config|
  config.orm = :active_record
end
```

To set up the database schema required by roper, run the following:

```
bundle exec rake roper:install:migrations
bundle exec rake db:migrate
```

Roper relies on the database configuration defined in your application's `config/database.yml` file.

#### MongoDB

To use MongoDB via via [Mongoid](https://docs.mongodb.org/ecosystem/tutorial/ruby-mongoid-tutorial/#ruby-mongoid-tutorial), set the `orm` configuration value to `:mongoid` in `config/initializers/roper.rb`:

```ruby
Roper.configure do |config|
  config.orm = :mongoid
end
```

Roper relies on the database configuration defined in your application's `config/mongoid.yml` file.
