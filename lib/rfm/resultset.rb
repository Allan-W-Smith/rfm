# This module includes classes that represent FileMaker data. When you communicate with FileMaker
# using, ie, the Layout object, you typically get back ResultSet objects. These contain Records,
# which in turn contain Fields, Portals, and arrays of data.
#
# Author::    Geoff Coffey  (mailto:gwcoffey@gmail.com)
# Copyright:: Copyright (c) 2007 Six Fried Rice, LLC and Mufaddal Khumri
# License::   See MIT-LICENSE for details

require 'bigdecimal'
require 'rfm/record'

module Rfm

  # The ResultSet object represents a set of records in FileMaker. It is, in every way, a real Ruby
  # Array, so everything you expect to be able to do with an Array can be done with a ResultSet as well.
  # In this case, the elements in the array are Record objects.
  #
  # Here's a typical example, displaying the results of a Find:
  #
  #   myServer = Rfm::Server.new(...)
  #   results = myServer["Customers"]["Details"].find("First Name" => "Bill")
  #   results.each {|record|
  #     puts record["First Name"]
  #     puts record["Last Name"]
  #     puts record["Email Address"]
  #   }
  #
  # =Attributes
  #
  # The ResultSet object has these attributes:
  #
  # * *field_meta* is a hash with field names for keys and Field objects for values; it provides 
  #   info about the fields in the ResultSet
  #
  # * *portal_meta* is a hash with table occurrence names for keys and arrays of Field objects for values;
  #   it provides metadata about the portals in the ResultSet and the Fields on those portals

  class Resultset < Array
  	include Config
    
    attr_reader :layout, :database, :server, :calling_object, :doc
    attr_reader :field_meta, :portal_meta, :include_portals, :datasource
    attr_reader :date_format, :time_format, :timestamp_format
    attr_reader :total_count, :foundset_count, :table
    #def_delegators :layout, :db, :database
    alias_method :db, :database
    
    class << self
    	alias_method :load_data, :new
    end
    
    # Initializes a new ResultSet object. You will probably never do this your self (instead, use the Layout
    # object to get various ResultSet obejects).
    #
    # If you feel so inclined, though, pass a Server object, and some +fmpxmlresult+ compliant XML in a String.
    #
    # =Attributes
    #
    # The ResultSet object includes several useful attributes:
    #
    # * *fields* is a hash (with field names for keys and Field objects for values). It includes an entry for
    #   every field in the ResultSet. Note: You don't use Field objects to access _data_. If you're after 
    #   data, get a Record object (ResultSet is an array of records). Field objects tell you about the fields
    #   (their type, repetitions, and so forth) in case you find that information useful programmatically.
    #
    #   Note: keys in the +fields+ hash are downcased for convenience (and [] automatically downcases on 
    #   lookup, so it should be seamless). But if you +each+ a field hash and need to know a field's real
    #   name, with correct case, do +myField.name+ instead of relying on the key in the hash.
    #
    # * *portals* is a hash (with table occurrence names for keys and Field objects for values). If your
    #   layout contains portals, you can find out what fields they contain here. Again, if it's the data you're
    #   after, you want to look at the Record object.
    def initialize(*args) # connection or calling_object or hash
    	#Was xml_response, calling_object, portals
    	#Was (server_obj, xml_response, layout_obj, portals=nil)

    	options = args.rfm_extract_options!      
      config :parent=>'calling_object'
      config sanitize_config(options, {}, true)
      
#       xml_response			= args[0] || options[:xml_response]
#       doc = XmlParser.parse(xml_response, :namespace=>false, :parser=>(state[:parser] rescue nil))
      
      error = 0 #doc.error
      check_for_errors(error, (server.state[:raise_on_401] rescue nil))
      
#       @doc							= doc
# 			@calling_object		= args[1] || options[:calling_object]

			@calling_object		= args[1] || options[:calling_object]
      @layout           = args[0] || options[:layout_object]
      
#       @database					= (@layout.database rescue nil) || (@calling_object.class == Rfm::Database ? @calling_object : options[:database_object])
#       @server           = (@database.server rescue nil) || (@calling_object.class == Rfm::Server ? @calling_object : options[:server_object])
#       @field_meta     ||= Rfm::CaseInsensitiveHash.new
#       @portal_meta    ||= Rfm::CaseInsensitiveHash.new
#       @include_portals  = args[2] || options[:include_portals]            

#       @datasource       = doc.datasource
#       meta              = doc.meta
#       resultset         = doc.resultset
# 
#       @date_format      = doc.date_format
#       @time_format      = doc.time_format
#       @timestamp_format = doc.timestamp_format
# 
#       @foundset_count   = doc.foundset_count
#       @total_count      = doc.total_count
#       @table            = doc.table
            
#       (layout.table = @table) if layout and layout.table_no_load.blank?
#       
#       parse_fields(doc)
#       
#       # This will always load portal meta, even if :include_portals was not specified.
#       # See Record for control of portal data loading.
#       parse_portals(doc)
#       
#       # These were added for loading resultset from file
#       # Kind of a hack. This should ideally condense down to just another option on the main @layout = ...
# 			#       unless @layout
# 			#       	@layout = @datasource['layout']
# 			#       	@layout.instance_variable_set '@database', @datasource['database']
# 			#       	@layout.instance_eval do
# 			#       		def database
# 			#       			@database
# 			#       		end
# 			#       	end
# 			#       end			
#       
#       return if doc.records.blank?
#       Rfm::Record.build_records(doc.records, self, @field_meta, @layout)
    end # initialize
    
    # Load Resultset data from file-spec or string
		#     def self.load_data(file_or_string)
		#     	self.new(file_or_string, nil)
		#     end
    
		def state(*args)
			get_config(*args)
		end
		
		def field_meta
			attributes['field_meta']
		end
		
		def portal_meta
			attributes['portal_meta']
		end		
		
		def datasource
			attributes['datasource']
		end
		
		def date_format
			attributes['date_format']
		end

		def time_format
			attributes['time_format']
		end
		
		def timestamp_format
			attributes['timestamp_format']
		end
		
		def total_count
			attributes['total_count']
		end		
		
		def foundset_count
			attributes['foundset_count']
		end
		
		def table
			attributes['table']
		end		
		
        
    def field_names
    	field_meta ? field_meta.keys : []
  	end
  	
  	def portal_names
  		portal_meta ? portal_meta.keys : []
  	end
  	
# 		def end_element_callback(cursor)
# 			elements = cursor.parent.obj
# 			elements.each{|k, v| cursor.set_attr_accessor(k, v) unless k == 'resultset'}
# 			# Why is this here? Seems to need it... how does it work?
# 			cursor.stack.unshift cursor
# 			layout && layout.instance_variable_get(:@resultset_meta).nil? && layout.resultset_meta = self.clone.replace([])
# 		end
    
    private
    
      def check_for_errors(code, raise_401)
        raise Rfm::Error.getError(code) if code != 0 && (code != 401 || raise_401)
      end
    
#       def parse_fields(doc)
#       	return if doc.fields.blank?
# 
#         doc.fields.each do |field|
#         	name = layout.field_mapping[field.name] || field.name rescue field.name
#           @field_meta[name] = Rfm::Metadata::Field.new(field)
#         end
#         (layout.field_names = field_names) if layout and layout.field_names_no_load.blank?
#       end

#       def parse_portals(doc)
#       	return if doc.portals.blank?
#         doc.portals.each do |relatedset|
#         	next if relatedset.blank?
#           table, fields = relatedset.table, {}
# 
#           relatedset.fields.each do |field|
#             name = field.name.to_s.gsub(Regexp.new(table + '::'), '')
#             fields[name] = Rfm::Metadata::Field.new(field)
#           end
# 
#           @portal_meta[table] = fields
#         end
#         (layout.portal_meta = @portal_meta) if layout and layout.portal_meta_no_load.blank?
#       end
    
			#   def convert_date_time_format(fm_format)
			#     fm_format.gsub!('MM', '%m')
			#     fm_format.gsub!('dd', '%d')
			#     fm_format.gsub!('yyyy', '%Y')
			#     fm_format.gsub!('HH', '%H')
			#     fm_format.gsub!('mm', '%M')
			#     fm_format.gsub!('ss', '%S')
			#     fm_format
			#   end
    
  end
end