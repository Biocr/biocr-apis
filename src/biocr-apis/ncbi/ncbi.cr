require "http/client"
require "json"

module Biocr
  module API::NCBI
    BASE_URL = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/"

    def self.request(query)
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
    def self.search(db : String, term : String, **options)
      query = "esearch.fcgi?db=#{db}&term=#{term}&retmode=json"
      query = create_url(query, options)

      response = JSON.parse(request(query))

      # Raises error message
      error_list = response["esearchresult"]["errorlist"]?
      raise error_list.to_s if error_list

      response["esearchresult"]["idlist"].as_a
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
    def self.summary(db, ids, **options)
      query = "esummary.fcgi?db=#{db}&id=#{ids.join(",")}"
      query = create_url(query, options)

      response = JSON.parse(request(query))

      # Raises error message
      error_list = response["esummaryresult"]?
      raise error_list.to_s if error_list

      uids = response["result"]["uids"]

      result = uids.each_with_object(Array(JSON::Any).new) do |uid, result|
        uid = uid.as_s
        if response["result"][uid].includes?("error")
          raise response["result"][uid]["error"].as_s
        else
          result << response["result"][uid]
        end
      end
      result
    end

    def self.fetch(db, ids, ret_mode = "fasta")
      query = "efetch.fcgi?db=#{db}&id=#{ids.join(",")}&rettype=#{ret_mode}"
      response = request(query)
    end

    def self.create_url(query, options)
      opt = String.build do |io|
        # if don't provide a retmode, will set a JSON by default
        io << "&retmode=json" unless options.has_key?(:retmode)
        options.each do |k,v|
          io << "&#{k}=#{v}"
        end
      end
      query + opt
    end
  end
end
