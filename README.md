jruby-rack-metrics
===========

This is a simple rack middleware that gathers metrics for the individual uri's served
by the wrapped application. It uses [Coda Hale's metrics library](https://github.com/codahale/metrics)
and thus requires jruby.

Usage
--------

Install it e.g. with bundler by adding it to your ``Gemfile`` file:

    source 'http://rubygems.org'
    gem 'sinatra'
    gem 'jruby-rack-metrics', '= 0.0.1', :git => "git://github.com/tomdz/jruby-rack-metrics.git"

and then run bundler:

    $ bundle install

Now you can use it like so in a Sinatra app:

    require 'rubygems'
    require 'bundler/setup'
    require 'sinatra'
    require 'jruby-rack-metrics'

    set :environment, :production
    use JrubyRackMetrics::Monitor, { :app_name => "HelloWorld", :jmx_enabled => true }

    get "/" do
      "Hello World"
    end


Requirements
------------

Requires [Rack](http://rack.rubyforge.org/) and [JRuby](http://jruby.org/). It also needs the
[core metrics library jar](https://github.com/codahale/metrics) in the classpath (it doesn't
bundle it at the moment).

Author
------

Original author: Thomas Dudziak

License
-------

Apache License version 2.0. See the LICENSE-2.0.txt file for the full
license.

