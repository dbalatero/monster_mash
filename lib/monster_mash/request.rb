module MonsterMash
  class InvalidRequest < StandardError; end

  class Request
    attr_accessor :options
    attr_accessor :errors

    def initialize(http_method, *args, &block)
      @handler = nil
      @value = nil

      self.options = { :method => http_method }
      execute_dsl(*args, &block)
    end

    def execute_dsl(*args, &block)
      instance_exec(*args, &block) if block_given?
    end

    def build_request
      Typhoeus::Request.new(self.uri, self.options)
    end

    def run_serial_request
      Typhoeus::Request.run(self.uri, self.options)
    end

    def valid?
      self.errors = []

      if !handler
        self.errors << 'You need to set a handler block.'
      end

      if !uri
        self.errors << 'You need to set a uri.'
      end

      self.errors.empty?
    end

    def uri(value = nil)
      if value
        @uri = value
      end
      @uri
    end

    def handler(&block)
      if block_given?
        @handler = block
      end
      @handler
    end

    # Typhoeus options.
    [:body, :headers, :timeout, :cache_timeout, :params,
     :user_agent, :follow_location, :max_redirects,
     :proxy, :disable_ssl_peer_verification].each do |method|
      class_eval <<-EOF
        def #{method}(value = nil, &block)
          assign_or_return_option!(:#{method}, value, &block)
        end
      EOF
    end

    private
    def assign_or_return_option!(name, value = nil)
      symbolized_name = name.to_sym
      if value
        self.options[symbolized_name] = value
      else
        self.options[symbolized_name]
      end
    end
  end
end
