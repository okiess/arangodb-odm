module ArangoDb
  module Queries
    class QueryResult < Array
    end

    module ClassMethods
      # PUT /_api/simple/all
      # Returns all documents of a collections. The call expects an JSON object as body with the following attributes:
      # collection: The identifier or name of the collection to query.
      # skip: The documents to skip in the query. (optional)
      # limit: The maximal amount of documents to return. The skip is applied before the limit restriction. (optional)
      def all(options = {})
        query_parameters = {'collection' => collection}        
        res = transport.put('/_api/simple/all', :body => query_parameters.merge(options).to_json)
        if res.code == 201 and res.parsed_response and res.parsed_response["result"]
          query_result = QueryResult.new
          res["result"].each {|json_doc| query_result << self.new.build(json_doc)}
          query_result
        end
      end
    end
  end
end
