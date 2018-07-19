require "enex/version"

require "builder"
require "base64"

module Enex
  class Note
    ATTRIBUTE_NAMES = [:export_date, :title, :content, :created, :updated, :tags, :resources]
    attr_accessor *ATTRIBUTE_NAMES

    def initialize(attributes = {})
      attributes.each do |k, v|
        raise "Unknown attribute: #{k.inspect}" unless ATTRIBUTE_NAMES.include?(k)
        send("#{k}=", v)
      end
      self.tags ||= []
      self.resources ||= []
    end

    def to_xml
      x = Builder::XmlMarkup.new
      x.instruct! :xml
      x.declare! :DOCTYPE, :"en-export", :SYSTEM, "http://xml.evernote.com/pub/evernote-export3.dtd"
      x.tag!("en-export", "export-date": time_to_s(export_date)){|x|
        x.note{|x|
          x.title title
          x.content{|x| x.cdata! content }
          x.created created if created
          x.update updated if updated
          tags.each{|tag| x.tag tag }
          # TODO note-attributes
          resources.each{|resource| x.resouce {|x| resource.build_xml_fragment(x) } }
        }
      }
      x.target!
    end

    def time_to_s(t)
      t.utc.strftime("%Y%m%dT%H%M%SZ")
    end

    class Resource
      ATTRIBUTE_NAMES = [:data, :mime, :width, :height, :duration]
      attr_accessor *ATTRIBUTE_NAMES

      def initialize(attributes = {})
        attributes.each do |k, v|
          raise "Unknown attribute: #{k.inspect}" unless ATTRIBUTE_NAMES.include?(k)
          send("#{k}=", v)
        end
      end

      def build_xml_fragment(x)
        x.data Base64.encode64(data), encoding: "base64"
        x.mime mime
        x.width width if width
        x.height height if height
        x.duration duration if duration
        # TODO recognition, resource-attributes, alternate-data
      end
    end
  end
end
