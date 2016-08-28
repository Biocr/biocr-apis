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

  it "fetch term and donwload a fasta file" do
    ncbi = Biocr::Apis::NCBI.new
    result = ncbi.search("protein", "Latrodectus katipo[Organism]")

    summary = ncbi.fetch("protein", result, "fasta")
    summary.includes?(">gi|167843271|gb|ACA03542.1|").should eq(true)
  end
end
