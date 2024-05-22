# frozen_string_literal: true

module Modulofcm

  class Configurator

    attr_reader :clients

    def initialize
      @clients = {}
    end

    def self.configure
      raise ArgumentError, 'A block is needed for Modulofcm.configure' unless block_given?

      builder = new
      yield builder

      Modulofcm.clients = builder.clients
    end

    def client(name)
      raise ArgumentError, 'A block is needed for Modulofcm::Configurator.client' unless block_given?

      client = Client.new(name: name)
      yield client

      validated_client, errors = validate_client(client)
      raise InvalidClient, errors.join('; ') unless validated_client

      @clients[name] = client
    end

    private

    def validate_client(client)
      @errors = []

      @errors << 'Required field: name' if client.name.blank?

      if [client.google_application_credentials_path, client.api_token, client.firebase_project_id].all?(&:present?)
        return [@errors.empty?, @errors]
      end

      return [@errors.empty?, @errors] if client.api_key.present?

      # rubocop:disable Layout/LineLength
      @errors << 'Either an API key for Legacy API (deprecated) either the API token, the Google application credentials path and the Firebase project id are required'
      # rubocop:enable Layout/LineLength

      [false, @errors]
    end

  end

end
