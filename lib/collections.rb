module ArangoDb
  module Collections
    module ClassMethods
      # POST /_api/collection
      # Creates an new collection with a given name. The request must contain an object with the following attributes.
      # name: The name of the collection.
      # waitForSync (optional, default: false): If true then the data is synchronised to disk before returning from a create or update of an document.
      # journalSize (optional, default is a configuration parameter): The maximal size of a journal or datafile. Note that this also limits the maximal 
      # size of a single object. Must be at least 1MB.
      # isSystem (optional, default is false): If true, create a system collection. In this case collection-name should start with an underscore. 
      # End users should normally create non-system collections only. 
      # API implementors may be required to create system collections in very special occasions, but normally a regular collection will do.
      # type (optional, default is 2): the type of the collection to create. The following values for type are valid:
      # 2: document collections
      # 3: edge collection
      def create_collection(options = {})
        res = transport.post("/_api/collection", :body => options.merge('name' => collection).to_json)
        if res.parsed_response and not res.parsed_response["code"] == 200
          res.parsed_response["id"]
        end
      end
    end
  end
end
