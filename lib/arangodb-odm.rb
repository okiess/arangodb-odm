require "rubygems"
require "httparty"
require "json"

require "collections"
require "queries"
require "indices"

module ArangoDb
  class Transport
    include HTTParty
    base_uri 'http://localhost:8529'
  end
  
  class Edge
    attr_accessor :db, :collection, :db_attrs, :location, :_id, :_rev, :_from, :_to
    attr_reader :attributes

    def initialize(collection, db_attrs = [])
      @attributes = {}; @collection = collection; @db_attr_names = db_attrs
    end

    def is_new?; self._id.nil?; end
    def to_json
      if @db_attr_names and @db_attr_names.any?
        values = {}
        @db_attr_names.each {|a| values[a] = self.attributes[a.to_s]}
        values.to_json
      else
        self.attributes.to_json
      end
    end
  end

  class Document
    attr_accessor :db, :collection, :db_attrs, :location, :_id, :_rev
    attr_reader :attributes

    def initialize(collection, db_attrs = [])
      @attributes = {}; @collection = collection; @db_attr_names = db_attrs
    end

    def is_new?; self._id.nil?; end
    def to_json
      if @db_attr_names and @db_attr_names.any?
        values = {}
        @db_attr_names.each {|a| values[a] = self.attributes[a.to_s]}
        values.to_json
      else
        self.attributes.to_json
      end
    end
  end

  class EdgeDocument < Document
    attr_accessor :_from, :_to
  end

  class Index
    attr_accessor :indices

    def initialize(indices)
      @indices = indices
    end
  end

  module Properties
    def self.included(klass)  
      klass.extend ClassMethods  
    end

    module ClassMethods
      # The collection to use for this document.
      def collection(value)
        (class << self; self; end).send(:define_method, 'collection') do
          value.to_s
        end
      end

      def skiplist(*fields)
        (class << self; self; end).send(:define_method, 'skiplist') do
          fields.to_a
        end
      end
      
      # Sets the transport class to use. Defaults to httparty.
      def transport(value)
        (class << self; self; end).send(:define_method, 'transport') do
          value
        end
      end

      # Sets the document value proxy to use.
      def target(value)
        (class << self; self; end).send(:define_method, 'target') do
          value
        end
      end

      # Callback that is being invoked before a document is first created.
      def before_create(value)
        self.send(:define_method, 'before_create') do
          value
        end
      end

      # Callback that is being invoked after a document is first created.
      def after_create(value)
        self.send(:define_method, 'after_create') do
          value
        end
      end

      # Callback that is being invoked before a document is updated.
      def before_save(value)
        self.send(:define_method, 'before_save') do
          value
        end
      end

      # Callback that is being invoked after a document was updated.
      def after_save(value)
        self.send(:define_method, 'after_save') do
          value
        end
      end

      # Callback that is being invoked before a document is destroyed.
      def before_destroy(value)
        self.send(:define_method, 'before_destroy') do
          value
        end
      end

      # Callback that is being invoked after a document was destroyed.
      def after_destroy(value)
        self.send(:define_method, 'after_destroy') do
          value
        end
      end

      def db_attrs(*attrs)
        @db_attr_names ||= []
        @db_attr_names << attrs.collect {|a| a.to_s} if attrs.any?
        (class << self; self; end).send(:define_method, 'db_attributes') do
          @db_attr_names ? @db_attr_names.first : []
        end
      end
    end
  end

  # Base class for ArangoDB documents. Subclass it to create your own collection 
  # specific document representations.
  #
  # Example:
  #
  # class ExampleDocument < ArangoDb::Base
  #  collection :examples
  #  skiplist [:a, :b]
  # end
  class Base
    include ArangoDb::Properties
    extend ArangoDb::Collections::ClassMethods
    extend ArangoDb::Queries::ClassMethods
    extend ArangoDb::Indices::ClassMethods
    transport ArangoDb::Transport
    db_attrs []
    attr_reader :target, :index

    def initialize
      @transport = self.class.transport
      if self.class.respond_to?(:skiplist) and self.class.skiplist
        @index = ArangoDb::Index.new(:skiplist => self.class.skiplist)
      end
    end

    def self.create(attributes = {})
      document = self.new.build(attributes)
      document.save
      document
    end
  
    # Override to run your own validations.
    def validate; true; end
  
    def changed?
      unless @target.is_new?
        res = @transport.head(@target.location)
        return (self._rev.to_s.gsub("\"", '') != res.headers['etag'].to_s.gsub("\"", ''))
      end
      false
    end

    def destroy
      unless is_new?
        if self.respond_to?(:before_destroy) and self.before_destroy
          self.send(self.before_destroy.to_sym)
        end
        res = @transport.delete(@target.location)
        if res.code == 200 or res.code == 202
          @target.location = nil; @target._id = nil; @target._rev = nil
          if self.respond_to?(:after_destroy) and self.after_destroy
            self.send(self.after_destroy.to_sym)
          end
          return true
        end
      end
      false
    end

    def to_json
      @target.to_json
    end

    protected
    # Delegates all unknown method invocations to the target.
    def method_missing(method, *args, &block)
      method = method.to_s
      if method[-1, 1] == '='
        @target.attributes[method.gsub('=', '')] = args.first unless ['_id=', '_rev='].include?(method)
      else
        val = @target.attributes[method]
        val = @target.send(method.to_sym) rescue nil unless val
        val
      end
    end
  end
  
  class DocumentBase < Base
    target ArangoDb::Document
    attr_reader :target, :index

    def initialize
      super
      @target = self.class.target.new(self.class.collection, self.class.db_attributes)
    end

    def self.find(document_handle)
      raise "missing document handle" if document_handle.nil?
      res = transport.get("/_api/document/#{document_handle}")
      res.code == 200 ? self.new.build(res.parsed_response) : nil
    end

    def self.keys
      res = transport.get("/_api/document?collection=#{collection}")
      res.code == 200 ? res.parsed_response['documents'] : []
    end

    def build(attributes = {})
      attributes.each {|k, v| self.send("#{k}=".to_sym, v) unless ['_id', '_rev'].include?(k)}
      self.target._id = attributes['_id'] if attributes['_id'] 
      self.target._rev = attributes['_rev'] if attributes['_rev']
      self.target.location = "/_api/document/#{self.target._id}" if attributes['_id']
      self
    end

    def save
      if validate
        if @target.is_new?
          if self.respond_to?(:before_create) and self.before_create
            self.send(self.before_create.to_sym)
          end
          res = @transport.post("/_api/document/?collection=#{@target.collection}&createCollection=true", :body => to_json)
          if res.code == 201 || res.code == 202
            @target.location = res.headers["location"]
            if @target.location and @target.location.include?("/_db")
              @target.db = @target.location.split("/")[2]
            end
            @target._id = res.parsed_response["_id"]
            @target._rev = res.headers["etag"]
            if self.respond_to?(:after_create) and self.after_create
              self.send(self.after_create.to_sym)
            end
            return @target._id
          end
        else
          if self.respond_to?(:before_save) and self.before_save
            self.send(self.before_save.to_sym)
          end
          res = @transport.put(@target.location, :body => to_json)
          @target._rev = res.parsed_response['_rev']
          if self.respond_to?(:after_save) and self.after_save
            self.send(self.after_save.to_sym)
          end
          return @target._rev
        end
      end
      nil
    end
  end
  
  class EdgeBase < Base
    target ArangoDb::Edge
    attr_reader :target, :index

    def initialize
      super
      @target = self.class.target.new(self.class.collection, self.class.db_attributes)
    end

    def self.find(document_handle)
      raise "missing edge handle" if document_handle.nil?
      res = transport.get("/_api/edge/#{document_handle}")
      res.code == 200 ? self.new.build(res.parsed_response) : nil
    end

    def self.keys
      res = transport.get("/_api/edge?collection=#{collection}")
      res.code == 200 ? res.parsed_response['documents'] : []
    end

    def build(attributes = {})
      attributes.each {|k, v| self.send("#{k}=".to_sym, v) unless ['_id', '_rev', 'from', 'to'].include?(k)}
      self.target._id = attributes['_id'] if attributes['_id'] 
      self.target._rev = attributes['_rev'] if attributes['_rev']
      self.target._from = attributes['_from'] if attributes['_from']
      self.target._to = attributes['_to'] if attributes['_to']
      self.target.location = "/_api/edge/#{self.target._id}" if attributes['_id']
      self
    end

    def save
      if validate
        if @target.is_new?
          if self.respond_to?(:before_create) and self.before_create
            self.send(self.before_create.to_sym)
          end
          
          puts "/_api/edge/?collection=#{@target.collection}&createCollection=true&from=#{@target._from}&to=#{@target._to}", to_json, "----"
          res = @transport.post("/_api/edge/?collection=#{@target.collection}&createCollection=true&from=#{@target._from}&to=#{@target._to}", :body => to_json)
          
          if res.code == 201 || res.code == 202
            @target.location = res.headers["location"]
            if @target.location and @target.location.include?("/_db")
              @target.db = @target.location.split("/")[2]
            end
            @target._id = res.parsed_response["_id"]
            @target._rev = res.headers["etag"]
            @target._from = res.parsed_response['_from']
            @target._to = res.parsed_response['_to']
            if self.respond_to?(:after_create) and self.after_create
              self.send(self.after_create.to_sym)
            end
            return @target._id
          end
        else
          if self.respond_to?(:before_save) and self.before_save
            self.send(self.before_save.to_sym)
          end
          res = @transport.put(@target.location, :body => to_json)
          @target._rev = res.parsed_response['_rev']
          if self.respond_to?(:after_save) and self.after_save
            self.send(self.after_save.to_sym)
          end
          return @target._rev
        end
      end
      nil
    end
  end
end
