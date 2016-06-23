require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:player) do
    Player.new({name: "Bob"})
  end

  let(:players_array) do
    [ 
      { name: "frank" },
      { name: "jill" },
      { name: "ben" },
      { name: "betty" },
      { name: "martha" },
      { name: "jon" }
    ]
  end

  subject { described_class.new }

  it { should have_many(:players) }
  it { should validate_presence_of(:players) }

  describe "creating a game" do
    it "cannot create a game without at least one player" do
      expect(subject).to_not be_valid
    end

    it "accepts nested attributes for player" do
      subject.players_attributes = [{name: "jill"}]
      expect(subject).to be_valid
    end

    it "can create a game with 6 players" do
      subject.players_attributes = players_array
      expect(subject).to be_valid
    end
  end
end
