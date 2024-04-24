# frozen_string_literal: true

require 'active_support/all'
require 'fcm'

require_relative 'modulofcm/version'
require_relative 'modulofcm/errors'
require_relative 'modulofcm/client'
require_relative 'modulofcm/configurator'

module Modulofcm

  class << self

    def configure(&block)
      Configurator.configure(&block)
    end

    def client(name)
      clients[name.to_sym]
    end

    attr_accessor :clients

  end

end
