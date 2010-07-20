module MonsterMash
  class HTTPError < StandardError
    attr_accessor :response
    attr_accessor :code
    attr_accessor :body
  end

  class Base
    @defaults = []
    @has_defaults = false

    attr_accessor :defaults
    attr_accessor :hydra
    attr_accessor :options

    def initialize(hydra, options = {})
      self.hydra = hydra
      self.options = options
    end

    def self.get(name, &setup_block)
      build_method(:get, name, &setup_block)
    end

    def self.post(name, &setup_block)
      build_method(:post, name, &setup_block)
    end

    def self.put(name, &setup_block)
      build_method(:put, name, &setup_block)
    end

    def self.delete(name, &setup_block)
      build_method(:delete, name, &setup_block)
    end

    def self.defaults(&block)
      if block_given? and !@has_defaults
        @has_defaults = true
        @defaults << block
      else
        @defaults
      end
    end

    def self.build_method(http_method, name, &setup_block) # :nodoc:
      if respond_to?(name)
        raise ArgumentError, "The method name \"#{name}\" is in use!"
      else
        method_name = "__real__" << name.to_s
        define_method(method_name) do |block, *args|
          self.class.execute(http_method, self.hydra, block, *args, &setup_block)
        end

        # Define the real instance method for this, and proxy
        # to the __real__method.
        class_eval <<-EOF
          def #{name}(*args, &block)
            #{method_name}(block, *args)
          end
        EOF

        (class << self; self; end).instance_eval do
          define_method(name) do |*args|
            execute(http_method, nil, nil, *args, &setup_block)
          end
        end
      end
    end

    def self.check_response_and_raise!(response)
      code = response.code.to_i
      if code < 200 or code >= 400
        error = MonsterMash::HTTPError.new("Got bad HTTP response! code: #{code}\n\n#{response.body}")
        error.response = response
        error.code = code
        error.body = response.body
        raise error
      end
    end

    def self.inherited(subclass)
      subclass.instance_variable_set("@defaults", defaults.dup)
    end

    private
    def self.execute(http_method, hydra, block, *args, &setup_block)
      # Create the request with defaults.
      request = MonsterMash::Request.new(http_method)
      request.apply_defaults(defaults)

      # Add in user-set values.
      request.execute_dsl(*args, &setup_block)

      # Validate request.
      if request.valid?
        if hydra.nil?
          # serial request.
          response = request.run_serial_request
          check_response_and_raise!(response)
          request.handler.call(response)
        else
          # parallel hydra request.
          typhoeus_request = request.build_request
          typhoeus_request.on_complete do |response|
            result, error = nil, nil
            begin
              check_response_and_raise!(response)
              result = request.handler.call(response)
            rescue => e
              error = e
            end
            block.call(result, error)
          end
          hydra.queue(typhoeus_request)
        end
      else
        raise MonsterMash::InvalidRequest,
          "Invalid request definition for #{name}:\n" <<
          request.errors.collect { |e| " * #{e}" }.join("\n")
      end
    end
  end
end
