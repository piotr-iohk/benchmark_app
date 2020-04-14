require_relative '../helpers/data_transfer'

include Helpers::DataTransfer

describe DataTransfer do
  describe "find_builds_to_transfer" do
    it "no builds" do
        b = find_builds_to_transfer 1, [1, 2, 3]
        expect(b).to eq []
    end

    it "all builds" do
        b = find_builds_to_transfer 4, [1, 2, 3]
        expect(b).to eq [1, 2, 3]
    end

    it "recent one" do
        b = find_builds_to_transfer 2, [1, 2, 3]
        expect(b).to eq [1]
    end

    it "recent two" do
        b = find_builds_to_transfer 3, [1, 2, 3]
        expect(b).to eq [1, 2]
    end
  end
end
