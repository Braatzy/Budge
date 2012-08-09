require 'erb'
require 'uri'

module BudgeAPI

  class ApiKeyAuth

    API_KEY_PARAMETER       = 'apiKey'
    API_SIGNATURE_PARAMETER = 'apiSignature'

    def self.generate_api_key_and_secret(website_url)

      @@SALT = "Klaatu barada nikto"

      api_key = Digest::MD5.hexdigest(Digest::MD5.hexdigest(website_url) + @@SALT)
      api_secret = SecureRandom.hex()

      return api_key, api_secret
    end

    def self.construct_signature_base_from_request(request)

      fullpath = request.fullpath

      if fullpath.start_with?('//')
        fullpath = fullpath.slice(1, fullpath.length)
      end

      uri = URI(fullpath)

      method  = request.request_method
      url     = uri.path
      params  = request.params

      self.construct_signature_base( method, url, params)
    end

    def self.construct_signature_base(method, url, params)

      modified_params = params.clone

      if modified_params[API_SIGNATURE_PARAMETER]
        modified_params.delete(API_SIGNATURE_PARAMETER)
      end

      signature_base = [ method.upcase, CGI::escape(url), CGI::escape( self.normalize_parameters(modified_params)) ].join("&")

      signature_base
    end

    def self.construct_signed_query(method, query, api_key)

      uri = URI(query)
      path = uri.path
      params = self.extract_parameters_from_query(uri.query)

      if !params[API_KEY_PARAMETER]
        params[API_KEY_PARAMETER] = api_key
      end

      signature_base = self.construct_signature_base( method, path, params)
      secret = self.retreive_api_secret(api_key)
      signature = self.sign( secret, signature_base)
      
      params[API_SIGNATURE_PARAMETER] = signature
      "#{path}?#{params.collect{|k,v| "#{k}=#{v}"}.join('&')}"
    end

    def self.sign_request(request, secret)

     self.sign( secret, self.construct_signature_base_from_request(request))

    end

    def self.verify_request(request)

      client_signature = request.params[API_SIGNATURE_PARAMETER]

      api_key = request.params[API_KEY_PARAMETER]

      if api_key
        api_consumer = ApiConsumer.find_by_api_key(api_key)

        if api_consumer 
          api_secret = api_consumer.api_secret
          server_signature = CGI::unescape(sign_request( request, api_secret))

          return client_signature == server_signature
        end
      end

      return false
    end

    def self.verify_query(method, query)

      p "Query: #{query}"

      uri = URI(query)
      url = uri.path
      params = self.extract_parameters_from_query(uri.query)

      client_signature = params[API_SIGNATURE_PARAMETER]
      api_key = params[API_KEY_PARAMETER]

      if api_key
        secret = self.retreive_api_secret(api_key)
        server_signature = CGI::unescape( self.sign( secret, self.construct_signature_base( method, query, api_key )))

        return client_signature == server_signature
      end

      return false
    end

    private

    def self.normalize_parameters(params)
      params.sort.inject("") { |str, (key, value)| str + "#{key.to_s}=#{value.to_s}&" }[0..-2]
    end

    def self.sign(secret, signature_base)
      ERB::Util.url_encode(Base64.encode64(OpenSSL::HMAC.digest("sha1", secret, signature_base)).strip)
    end

    def self.extract_parameters_from_query(query)
      params = {}
      if query 
        params_array = CGI::parse(query)
        if params_array.length > 0
          params_array.each { |k,v| params.store( k, v[0]) }
        end
      end
      params
    end

    def self.retreive_api_secret(api_key)
      api_consumer = ApiConsumer.find_by_api_key(api_key)

      if api_consumer 
        api_secret = api_consumer.api_secret
        return api_secret
      else
        throw ArgumentError
      end
    end
  end
end
