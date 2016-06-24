require 'rails_helper'

RSpec.describe FrameService do
  
  let!(:game) do
    Game.create(players_attributes: [{ name: "Bob" }])
  end

  let!(:player) do
    game.players.first
  end

  let(:pins_down) do
    4
  end

  let(:frame_svc) do
    FrameService.new(player_id: player.id, pins_down: pins_down)
  end

  subject { frame_svc.update_player_frames! }

  describe "#update_player_frame!" do
    context "first frame" do
      it "builds a new frame at frame number 1 for a player" do
        subject
        player.reload
        expect(player.frames.count).to eq 1
        expect(player.frames.last.frame_number).to eq 1
      end
    end
    context "not the first frame" do
      it "increases the frame_number by one" do
        allow_any_instance_of(FrameService).to receive(:update_roll!).and_return(true)
        frame = Frame.create(frame_number: 1, status: "closed", player: player)
        subject
        player.reload
        expect(player.frames.last.frame_number).to eq 2
        expect(player.frames.count).to eq 2
      end
    end

    context "when player has 10 frames" do
      let!(:ten_frames) do
        frames = []
        frame = 0
        while frame < 10 do
          f = Frame.create(frame_number: frame + 1, status: "closed", player: player)
          frame += 1
        end
      end
      it "cannot exceed 10 frames" do
        subject
        player.reload
        expect(player.frames.count).to eq 10
      end
    end
  end
end