require "http/client"
require "xml"
require "json"

module Biocr
  module Apis
    class NCBI

      struct Summary
        property uid, title
        def initialize()
          @uid = String.new
          @title = String.new
        end
      end

      BASE_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/"

      def request(query)
        query = query.gsub(" ", "%20")
        response = HTTP::Client.get("#{BASE_URL}#{query}")
        # TODO: handle possible errors
        response.body
      end

      def search(db : String, term : String)
        query = "esearch.fcgi?db=#{db}&term=#{term}&retmode=json"
        response = JSON.parse(request(query))

        count = response["esearchresult"]["count"].as_s
        ids = response["esearchresult"]["idlist"]

        if count.to_i > 0
          ids.to_a
        else
          [] of String
        end
      end

      def summary(db, ids)
        result = Array(Summary).new

        query = "esummary.fcgi?db=#{db}&id=#{ids.join(",")}&retmode=json"

        response = JSON.parse(request(query))
        uids = response["result"]["uids"]

        uids.map do |uid|
          uid = uid.as_s
          if response["result"][uid].includes?("error")
            raise response["result"][uid]["error"].as_s
          else
            summary = Summary.new
            summary.title = response["result"][uid]["title"].as_s
            summary.uid = response["result"][uid]["title"].as_s
            result << summary
          end
        end
        result
      end

      def fetch(db, ids, ret_mode = "fasta")
        query = "efetch.fcgi?db=#{db}&id=#{ids.join(",")}&rettype=#{ret_mode}"
        response = request(query)
      end

    end
  end
end
