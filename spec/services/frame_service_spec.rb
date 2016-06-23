require 'rails_helper'

RSpec.describe FrameService do
  
  let!(:game) do
    Game.create(players_attributes: [{ name: "Bob" }])
  end

  let(:player) do
    game.players.first
  end

  let(:frame_svc) do
    FrameService.new(player)
  end

  let(:ten_frames) do
    frames = []
    frame = 0
    while frame < 10 do
      f = Frame.create(frame_number: frame + 1)
      frame += 1
      frames << f
    end
    frames
  end

  subject { frame_svc.build! }

  describe "#build!" do
    context "first frame" do
      it "builds a new frame at frame number 1 for a player" do
        subject
        expect(player.frames.count).to eq 1
        expect(subject.frame_number).to eq 1
      end
    end
    context "not the first frame" do
      it "increases the frame_number by one" do
        frame = Frame.create(frame_number: 1)
        player.frames << frame
        subject
        expect(subject.frame_number).to eq 2
        expect(player.frames.count).to eq 2
      end

      it "cannot exceed 10 frames" do
        player.frames = ten_frames
        subject
        expect(player.frames.count).to eq 10
      end
    end
  end
end