require 'singleton'

module Papermill

  # The Storage class inherits from Array, and thus can be used in a very simple
  # and predictable way. This is used by the Collector to save requests until
  # they are ready to be sent to the remote server, which is handled by the
  # Agent class.
  class Storage < Array
    include Singleton

    class << self
      # TODO: We need a mutex sync around adding items to storage

      def store
        instance
      end

      def clear
        store.clear
      end

      def size
        store.size
      end

      def empty?
        store.empty?
      end
    end
  end

end

