require_relative 'spec_helper'

include Helpers

describe Helpers::DataTransfer do
  describe "find_builds_to_transfer" do
    it "no builds" do
      b = DataTransfer.find_builds_to_transfer 1, [3,2,1]
      expect(b).to eq [2, 3]
    end

    it "all builds" do
      b = DataTransfer.find_builds_to_transfer 4, [1, 2, 3]
      expect(b).to eq []
    end

    it "recent one" do
      b = DataTransfer.find_builds_to_transfer 2, [1, 2, 3]
      expect(b).to eq [3]
    end

    it "recent two" do
      b = DataTransfer.find_builds_to_transfer 3, [1, 2, 3]
      expect(b).to eq []
    end
  end
end
