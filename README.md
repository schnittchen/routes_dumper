# RoutesDumper

Every time your routes.rb changes, a detailed summary is dumped to the `routes.txt`
file at the Rails app root. The contents are similar to a `rake routes` output. The major differences are:

* fixed width indentations, so routes.txt is diffable against backed up versions
* MUCH faster if you use bundler, since the routes are already loaded inside the app

## Installation

Add this line to your application's Gemfile, preferrably inside the `development` group:

    gem 'routes_dumper'

And then execute:

    $ bundle

## Usage

Nothing to do. You should see the `routes.txt` after the first request of the server.
It will be regenerated each time `routes.rb` is altered and a request is made.

## Limitations

I have done virtually no testing. It works for me on Rails 3.2.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
