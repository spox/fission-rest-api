require 'fission-rest-api'

module Fission
  module RestApi

    class Repository < Fission::Callback

      PATH_PARTS = ':action'

      include Fission::Utils::RestApi

      # Determine validity of message
      #
      # @param message [Carnivore::Message]
      # @return [TrueClass]
      def valid?(message)
        super do |_|
          # only care that it's an HTTP request
          message[:message][:request] &&
            message[:message][:connection]
        end
      end

      # Process request and return result
      #
      # @param message [Carnviore::Message]
      def execute(message)
        failure_wrap(message) do |_|
          info = token_lookup(message[:message][:request])
          unless(info.empty?)
            path = parse_path(message[:message][:request].path)
            asset_key = File.join('repositories', info[:account_name], path[:_leftovers])
            info "Processing repository request for `#{info[:account_name]}` for item: #{asset_key}"
            if(config.get(:repository, :stream)
              debug "Delivery of asset `#{asset_key}` via stream"
              begin
                message[:message][:request].respond(:ok, :transfer_encoding => :chunked)
                asset_store.get(asset_key) do |chunk|
                  message[:message][:request] << chunk
                end
              ensure
                message[:message][:request].finish_response
              end
            else
              debug "Delivery of asset `#{asset_key}` via 302 redirect"
              message.confirm!(
                :code => :found,
                'Location' => asset_store.url(asset_key)
              )
            end
          else
            if(message[:message][:request][:authentication].empty?)
              message.confirm!(
                :code => :unauthorized,
                'WWW-Authenticate' => 'Basic realm="Restricted storage"'
              )
            else
              message.confirm!(:code => :unauthorized)
            end
          end
        end
      end

    end
  end
end

Fission.register(:rest_api, :repository, Fission::RestApi::Repository)