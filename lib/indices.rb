module ArangoDb
  module Indices
    module ClassMethods
      
      # POST /_api/index?collection=collection-identifier
      # Creates a skip-list index for the collection collection-identifier, if it does not already exist. The call expects an object 
      # containing the index details.
      # type: must be equal to "skiplist".
      # fields: A list of attribute paths.
      # unique: If true, then create a unique index.
      def create_skiplist(fields)
        query_parameters = { "type" => "skiplist", "unique" => false, "fields" => fields }
        endpoint = "/_api/index?collection=#{collection}"
        res = transport.post(endpoint, :body => query_parameters.to_json)
        if res.parsed_response and not (res.parsed_response["code"] == 200 or res.parsed_response["code"] == 201)
          raise "Couldn't create skip list index: #{res.parsed_response["code"]}"
        end
      end

      def ensure_indices
        create_skiplist(skiplist) if skiplist
        true
      end
    end
  end
end
