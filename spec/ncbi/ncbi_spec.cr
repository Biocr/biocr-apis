require "../spec_helper"
include Biocr::Apis

describe Biocr::Apis do
  it "should search for SRA and Term" do
    json = File.read("#{__DIR__}/spec_files/search_fetch_sra.json")

    ncbi = Biocr::Apis::NCBI.new
    result = ncbi.search("sra", "papain")
    result.size.should eq(20)
    result.to_pretty_json.should eq(json)
  end
end
