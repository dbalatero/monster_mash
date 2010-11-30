module MonsterMash
  class InvalidRequest < StandardError; end

  class Request
    attr_accessor :options
    attr_accessor :errors
    attr_accessor :caller_klass

    # Creates a new Request wrapper object.
    #
    # @param [Symbol] type of HTTP request - :get, :post, :delete, :put
    def initialize(http_method, *args, &block)
      @handler = nil
      @value = nil

      self.options = { :method => http_method }
      execute_dsl(*args, &block)
    end

    def method_missing(method, *args, &block)
      if caller_klass && caller_klass.respond_to?(method)
        caller_klass.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to?(method)
      (caller_klass && caller_klass.respond_to?(method)) || super
    end

    def apply_defaults(default_blocks)
      default_blocks.each { |block| execute_dsl(&block) }
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
        if self.options[symbolized_name].respond_to?(:merge) and value.respond_to?(:merge)
          self.options[symbolized_name].merge!(value)
        else
          self.options[symbolized_name] = value
        end
      else
        self.options[symbolized_name]
      end
    end
  end
end
