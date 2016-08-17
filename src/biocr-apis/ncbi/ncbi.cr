require "http/client"
require "xml"
require "json"

module Biocr
  module Apis
    class NCBI
      BASE_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
      SEARCH_BASE = "esearch.fcgi?"
      FETCH_BASE = "efetch.fcgi?"

      def search(db : String, term : String)
        ids = Array(String).new
        query = SEARCH_BASE + "db=#{db}&term=#{term}"
        response = HTTP::Client.get BASE_URL + query
        response = XML.parse(response.body).first_element_child.try &.xpath_node("IdList")
        
        response.try &.children.select(&.element?).each do |element|
          if element.content
            ids << element.content as String
          end
        end
        fetch(ids)
      end

      def fetch(ids : Array(String))
        json = Array(Array(JSON::Any)).new

        query = FETCH_BASE + "db=sra&id=#{ids.join(",")}"
        response = HTTP::Client.get BASE_URL + query
        xml_to_json(response.body)
      end

      def xml_to_json(md)
        json = Array(JSON::Any).new
        result = ""
        nodes = XML.parse(md).root

        if nodes
          nodes.try &.children.each do |c|
            maps = c.children.map do |m|
              [m.name, get_childs_from_node(m)]
            end

            unless maps.empty?
              result = String.build do |io|
                io.json_object do |object|
                  object.field c.name, maps.to_h
                end
              end
              json << JSON.parse(result)
            end
          end
        end
        json
      end

      def get_childs_from_node(node)
        childs = node.children
        result = Array(Array(String|Nil)).new

        childs.each do |c|
          result << [c.name, c.content]
        end
        result.to_h
      end

    end
  end
end
