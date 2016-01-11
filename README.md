# roper

Rails OAuth2 Provider. Implements all protocol flows defined in the [OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749), as well as support for the following extension grants:

- [JSON Web Tokens (JWT) as authorization grants](https://tools.ietf.org/html/rfc7523)

## Installation

Add the following dependency to your Rails application's `Gemfile` file:

    gem 'roper'


Then run `bundle install` to install roper.

## Configuration

Run the following generator to install roper configuration files into your application.

```
bundle exec rails generate roper:install
```

This will copy the following files into your application:

`config/initializers/roper.rb` - Initializer where you can configure roper

`config/locales/roper.en.yml` - Locale file used by the [authorization request](https://tools.ietf.org/html/rfc6749#section-4.1.1) view

Mount the roper engine by adding the following to your `config/routes.rb` file:

```ruby
mount Roper::Engine, at: "/oauth"
```

All roper provided endpoints will be scoped under the `/oauth` path.


### ORM Configuration

Roper supports persisting data to a relational database via ActiveRecord, or to MongoDB via [Mongoid](https://docs.mongodb.org/ecosystem/tutorial/ruby-mongoid-tutorial/#ruby-mongoid-tutorial). Roper assumes that your application already has a configured and functioning database connection.

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

#### MongoDB

To use MongoDB via [Mongoid](https://docs.mongodb.org/ecosystem/tutorial/ruby-mongoid-tutorial/#ruby-mongoid-tutorial), set the `orm` configuration value to `:mongoid` in `config/initializers/roper.rb`:

```ruby
Roper.configure do |config|
  config.orm = :mongoid
end
```

## License

MIT

Copyright 2015 Brian Ploetz

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

