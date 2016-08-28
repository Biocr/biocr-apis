require "../spec_helper"
include Biocr::Apis

describe Biocr::Apis do
  it "search for DB and Term" do
    ncbi = Biocr::Apis::NCBI.new
    result = ncbi.search("sra", "papain")
    result.size.should eq(20)
  end

  it "get summary from search ids" do
    ncbi = Biocr::Apis::NCBI.new
    result = ncbi.search("popset", "Latrodectus katipo[Organism]")
    result.size.should eq(6)

    summary = ncbi.summary("popset", result)
    summary.size.should eq(6)
  end

  it "raise error with invalid querys" do
    ncbi = Biocr::Apis::NCBI.new
    result = ncbi.search("popset", "Latrodectus katipo[Organism]")
    expect_raises Exception, "cannot get document summary" do
      ncbi.summary("biosample", result)
    end
  end
end
