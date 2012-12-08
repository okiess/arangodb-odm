module ArangoDb
  module Queries
    class QueryResult < Array
      # TODO
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

      def attribute(attr_name)
        @attribute = attr_name
        self
      end

      def left(number)
        @left = number
        self
      end
      
      def right(number)
        @right = number
        self
      end

      def closed(boolean)
        @closed = boolean
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
        options['left'] = @left if @left
        options['right'] = @right if @right
        options['attribute'] = @attribute if @attribute
        options['closed'] = @closed if @closed
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
      #
      # PUT /_api/simple/range
      # This will find all documents within a given range. You must declare a skip-list index on the attribute in order 
      # to be able to use a range query.The call expects a JSON hash array as body with the following attributes:
      # collection: The identifier or name of the collection to query.
      # attribute: The attribute path to check.
      # left: The lower bound.
      # right: The upper bound.
      # closed: If true, use interval including left and right, otherwise exclude right, but include left.
      # skip: The documents to skip in the query. (optional)
      # limit: The maximal amount of documents to return. (optional)
      def all(options = {})
        query_parameters = {'collection' => collection}; endpoint = '/_api/simple/all'
        if options and options['example'] and options['example'].any?
          endpoint = '/_api/simple/by-example'
        elsif options and options['left'] and options['right'] and options['attribute']
          endpoint = '/_api/simple/range'
        end
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
      
      def attribute(attr_name)
        Query.new(self).attribute(attr_name)
      end

      def left(number)
        Query.new(self).left(number)
      end
      
      def right(number)
        Query.new(self).right(number)
      end
      
      def closed(boolean)
        Query.new(self).closed(boolean)
      end
    end
  end
end
