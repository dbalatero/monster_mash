monster_mash
============

* Typhoeus is an ancient monster.
* A monster mash is a dance party.
* This library inspired by John Nunemaker's awesomely useful HTTParty.
* By law, all Ruby libraries have to have dumbass names.

This library wraps `Typhoeus` and `Typhoeus::Hydra` and exposes an easy-to-use DSL for quickly building libraries to interact with HTTP resources. Every method you write will automatically export serial (blocking) and parallel (non-blocking) methods, so you can easily parallelize your HTTP code when possible.

Writing a method
----------------

monster_mash has a Sinatra-like syntax, and lets you build client API methods using the 
4 HTTP verbs:

* `get(method_name, &definition_block)`
* `post(method_name, &definition_block)`
* `put(method_name, &definition_block)`
* `delete(method_name, &definition_block)`

Within each `definition_block`, you can set various Typhoeus options.

* `uri` **(required)** - the URI to hit
* `handler` **(required)** - a block to handle an HTTP response
* `params` - hash of URI params
* `body` - post body
* `headers` - hash of HTTP headers to send
* `timeout` - how long to timeout
* `cache_timeout` - how long to keep HTTP calls cached
* `user_agent` - a User-Agent string to send
* `max_redirects` - max number of redirects to follow
* `disable_ssl_peer_verification` - whether to disable SSL verification

Example: Google JSON search
---------------------------

    class GoogleJson < MonsterMash::Base
      VERSION = '1.0'

      # Creates a method called +search+ that takes
      # a single +query+ parameter.
      get(:search) do |query|
        uri "http://ajax.googleapis.com/ajax/services/search/web"
        params 'v' => VERSION,
               'q' => query,
               'rsz' => 'large'
        handler do |response|
          json = JSON.parse(response.body)

          # returns results
          json['responseData']['results']
        end
      end
    end

To make serial (blocking) calls using this code, you would then call the class method:

    # blocks
    results = GoogleJson.search("my search query")
    results.each do |result|
      puts result['unescapedUrl']
      # do other stuff with the response
    end

The `search(query)` method returns whatever your `handler` block returns.

To make parallel (non-blocking) calls, you need an instance of Typhoeus::Hydra:

    hydra = Typhoeus::Hydra.new
    google = GoogleJson.new(hydra)
    10.times do
      google.search("my query") do |results, error|
        if error
          # handle error
        else
          results.each do |result|
            puts result['unescapedUrl']
          end
        end
      end
    end

    # blocks until all 10 queries complete.
    hydra.run

Calling helper methods from a handler block
-------------------------------------------

monster_mash will correctly delegate method calls from your handler block to your API class. Example:

    class GoogleJson < MonsterMash::Base
      VERSION = '1.0'

      # Creates a method called +search+ that takes
      # a single +query+ parameter.
      get(:search) do |query|
        uri "http://ajax.googleapis.com/ajax/services/search/web"
        params 'v' => VERSION,
               'q' => query,
               'rsz' => 'large'
        handler do |response|
          json = JSON.parse(response.body)

          # Calls the correct method on GoogleJson.
          parse_results(json)
        end
      end

      def self.parse_results(json)
        json['responseData']['results']
      end
    end

Setting defaults
----------------

If you have Typhoeus settings you want to happen for every request, you can set them in a defaults block:

    class GoogleJson < MonsterMash::Base
      defaults do
        user_agent "GoogleJson Ruby Library"
        disable_ssl_peer_verification true
      end

      # ...
    end

As well, if you set `params` or `headers` in the `defaults` block, any `params` or `headers` added later will be `merge`d into the hash.

    class GoogleJson < MonsterMash::Base
      defaults do
        params 'api_key' => 'fdas'
      end

      # The full params hash will look like:
      #   :q => +query+,
      #   :v => '1.0',
      #   :api_key => 'fdas'
      get(:search) do |query|
        params 'q' => query,
               'v' => '1.0'
        uri "..."
        handler do |response|
          # ...
        end
      end
    end

Error Handling
--------------

* All serial (blocking) methods will simply raise an error if anything wrong happens. You just need to `rescue` said error.
* When interacting with Hydra requests, the block you pass to it will receive an error to it if any error was caught during the `handler`'s run. You need to check for the error in your block and handle it there.

Example Projects using monster_mash
-----------------------------------
* http://github.com/dbalatero/alchemy_api

Note on Patches/Pull Requests
-----------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2010 David Balatero. See LICENSE for details.
