require 'regrapher/client'
require 'regrapher/parser'

module Regrapher

  class << self

    def client=(client)
      @client = client
    end

    def client
      @client ||= Client.new
    end
  end
end