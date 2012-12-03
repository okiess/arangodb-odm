module ArangoDb
  module Queries
    class QueryResult < Array
    end

    class Query
      def initialize(model)
        @model = model
      end

      def where(hash)
        @where ||= {}
        @where.merge!(hash)
        self
      end

      def limit(number)
        @limit = number
        self
      end

      def skip(number)
        @skip = number
        self
      end

      def first
        @model.first(query_parameters)
      end

      def all
        @model.all(query_parameters)
      end
      
      private
      def query_parameters
        options = {}
        options['limit'] = @limit if @limit
        options['skip'] = @skip if @skip
        options['example'] = @where if @where
        options
      end
    end

    module ClassMethods
      # PUT /_api/simple/all
      # Returns all documents of a collections. The call expects an JSON object as body with the following attributes:
      # collection: The identifier or name of the collection to query.
      # skip: The documents to skip in the query. (optional)
      # limit: The maximal amount of documents to return. The skip is applied before the limit restriction. (optional)
      #
      # PUT /_api/simple/by-example
      # This will find all documents matching a given example.
      # The call expects a JSON hash array as body with the following attributes:
      # collection: The identifier or name of the collection to query.
      # example: The example.
      # skip: The documents to skip in the query. (optional)
      # limit: The maximal amount of documents to return. (optional)
      def all(options = {})
        query_parameters = {'collection' => collection}; endpoint = '/_api/simple/all'
        endpoint = '/_api/simple/by-example' if options and options['example'] and options['example'].any?
        res = transport.put(endpoint, :body => query_parameters.merge(options).to_json)
        if res.code == 201 and res.parsed_response and res.parsed_response["result"]
          query_result = QueryResult.new
          res["result"].each {|json_doc| query_result << self.new.build(json_doc)}
          query_result
        end
      end

      # PUT /_api/simple/first-example
      # This will return the first document matching a given example.
      # The call expects a JSON hash array as body with the following attributes:
      # collection: The identifier or name of the collection to query.
      # example: The example.
      def first(options = {})
        query_parameters = {'collection' => collection}; endpoint = '/_api/simple/first-example'
        res = transport.put(endpoint, :body => query_parameters.merge(options).to_json)
        if res.code == 200 and res.parsed_response and (json_doc = res.parsed_response["document"])
          self.new.build(json_doc)
        end
      end

      def where(hash)
        Query.new(self).where(hash)
      end

      def limit(number)
        Query.new(self).limit(number)
      end
      
      def skip(number)
        Query.new(self).skip(number)
      end
    end
  end
end
