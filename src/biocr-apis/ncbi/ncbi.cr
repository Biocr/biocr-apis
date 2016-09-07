require "http/client"
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

      # Returns a list of primary IDS
      #
      # See the online documentations for more explanations
      # [ESearch](http://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.ESearch)
      #
      # Example:
      # ```
      # NCBI.search("protein", "Latrodectus katipo[Organism]")
      # => ["167843271", "167843269", "167843267"....]
      #
      def search(db : String, term : String, **options)
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

      # Returns document summaries from a list of IDs
      #
      # See the online documentations for more explanations
      # [ESummary](http://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.ESummary)
      #
      # **Parameters**
      #
      # **DB:** Database from which to retrieve DocSums. The value must be a valid Entrez database name.
      #
      # **ids:** UID list. Either a single UID or a comma-delimited list of UIDs may be provided.
      #          All of the UIDs must be from the database specified by DB.
      #
      # **ret_mode:** By default, the summary will return a **JSON**, but you can specify an **XML**
      #
      def summary(db, ids, ret_mode = "json")
        query = "esummary.fcgi?db=#{db}&id=#{ids.join(",")}&retmode=#{ret_mode}"

        response = JSON.parse(request(query))
        uids = response["result"]["uids"]

        result = uids.each_with_object(Array(Summary).new) do |uid, result|
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
