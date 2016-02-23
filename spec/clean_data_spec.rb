require "spec_helper"
require './clean_data.rb'

describe CleanData do
  it "gets the right number of events for 2014" do
    file = File.open("for_database/2014_ready.txt", "r")
    count = 0
    file.each do |line|
      count += 1
    end
    expect(count).to eq 40
  end

  it "gets the right number of events for 1991" do
    file = File.open("for_database/1991_ready.txt", "r")
    count = 0
    file.each do |line|
      count += 1
    end
    expect(count).to eq 310
  end
end
