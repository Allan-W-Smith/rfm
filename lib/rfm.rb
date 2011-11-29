#Rfm = Module.new unless defined? Rfm
module Rfm
end

Rfm::PATH = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(Rfm::PATH) unless $LOAD_PATH.include?(Rfm::PATH)

require 'rfm/utilities/core_ext'
require 'rfm/utilities/case_insensitive_hash'
require 'rfm/utilities/config'
require 'rfm/utilities/factory'
require 'rfm/version.rb'

module Rfm

	if $0.to_s.match(/irb|rails|bundle/) # was ENV['_']
  	puts "Using gem ginjo-rfm version: #{::Rfm::VERSION}"
  end
  
  class CommunicationError  < StandardError; end
  class ParameterError      < StandardError; end
  class AuthenticationError < StandardError; end

  autoload :Error,     'rfm/error'
  autoload :Server,    'rfm/server'
  autoload :Database,  'rfm/database'
  autoload :Layout,    'rfm/layout'
  autoload :Resultset, 'rfm/resultset'
  autoload :Record,    'rfm/record'
  autoload :Base,      'rfm/utilities/base'
  autoload :XmlParser, 'rfm/utilities/xml_parser'

	module Metadata
		autoload :Script, 'rfm/metadata/script'
		autoload :Field, 'rfm/metadata/field'
		autoload :FieldControl, 'rfm/metadata/field_control'
		autoload :ValueListItem, 'rfm/metadata/value_list_item'
	end
	 
end

