require "../spec_helper"
include Biocr::API

describe Biocr::Apis do

  it "create a url with proper options" do
    result = NCBI.create_url("esearch.fcgi?db=sra&term=papain", {retmax: 10})
    result.should eq("esearch.fcgi?db=sra&term=papain&retmode=json&retmax=10")
  end

  it "does search" do
    result = NCBI.search("sra", "papain")
    result.size.should eq(20)
  end

  it "search by retmax" do
    result = NCBI.search("sra", "papain", retmax: 10)
    result.size.should eq(10)
  end

  it "get summary from search ids" do
    result = NCBI.search("popset", "Latrodectus katipo[Organism]")
    result.size.should eq(6)

    summary = NCBI.summary("popset", result)
    summary.size.should eq(6)
  end

  it "raise error with invalid querys" do
    result = NCBI.search("popset", "Latrodectus katipo[Organism]")
    expect_raises Exception, "cannot get document summary" do
      NCBI.summary("biosample", result)
    end
  end

  it "fetch term and donwload a fasta file" do
    result = NCBI.search("protein", "Latrodectus katipo[Organism]")

    summary = NCBI.fetch("protein", result, "fasta")
    summary.includes?(">gi|167843271|gb|ACA03542.1|").should eq(true)
  end
end
