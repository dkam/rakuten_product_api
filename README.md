# RakutenProductApi

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/rakuten_product_api`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

[API Documentation](https://developers.rakutenmarketing.com/console/registry/resource/_system/governance/apimgt/applicationdata/provider/RakutenMarketing/artifacts/API_Developer_Portal-Acquiring_Your_Access_Token_Guide.pdf)

[API Overview](https://developers.rakutenmarketing.com/subscribe/)
[API Keys](https://developers.rakutenmarketing.com/subscribe/site/pages/subscriptions.jag)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rakuten_product_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rakuten_product_api

## Usage

The library can be configured with an initializer. For Rails, create the file `config/initializers/rakuten.rb`

```ruby
RakutenProductApi.configure do |config|
  config.sid             = 'your-site-id'
  config.username        = 'your-rakuten-username'
  config.password        = 'your-rakuten-password'
  config.consumer_key    = 'your-consumer-key'
  config.consumer_secret = 'your-consumer-secret'
end
```

Additionally, you can configure a Merchant ID (mid).  This be applied to all requests and restrict queries to that merchant.

Once you have configured the library, you can create a client.

```ruby
client = RakutenProductApi::Client.new

client.username
=> "dkam"
```

Your client should be threadsafe.  Configuration values are local to your instance.z


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

If you create a file `config.rb`, it will be loaded by `bin/console`, allowing you to configure keys and markets.

```ruby
RakutenProductApi.configure do |config|
  config.sid             = 'your-site-id'
  config.username        = 'your-rakuten-username'
  config.password        = 'your-rakuten-password'
  config.consumer_key    = 'your-consumer-key'
  config.consumer_secret = 'your-consumer-secret'
end
```


To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dkam/rakuten_product_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
