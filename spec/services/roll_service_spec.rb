require 'rails_helper'

RSpec.describe RollService do

  let!(:game) do
    Game.create(players_attributes: [{ name: "Bob" }])
  end

  let(:frame) do
    Frame.create(frame_number: 1)
  end

  let(:player) do
    game.players.first
  end

  let(:pins_down) { 4 } 

  let(:roll_svc) do
    RollService.new(player: player, pins_down: pins_down, frame: frame)
  end

  subject { roll_svc.add_roll! }

  describe "#add_roll!" do
    context "first roll" do
      it "should add roll_one_val to the current frame" do
        player.frames << frame
        allow_any_instance_of(RollService).to receive(:update_score!).and_return(true)
        subject
        frame.reload
        expect(frame.roll_one_val).to eq 4
      end

      it "should not change status if not a strike" do
        player.frames << frame
        subject
        frame.reload
        expect(frame.status).to eq "open"
      end  

      it "should change status to pending if strike" do
        pins_down = 10
        player.frames << frame
        roll_svc = RollService.new(player: player, pins_down: pins_down, frame: frame)
        roll_svc.add_roll!
        frame.reload
        expect(frame.roll_one_val).to eq 10
        expect(frame.status).to eq "pending"
      end
    end

    context "second roll" do
      it "should add roll_two_val to the current frame" do
        frame.roll_one_val = 5
        frame.save
        frame.reload
        player.frames << frame
        subject
        frame.reload
        expect(player.frames.last.roll_two_val).to eq 4
      end

      it "should change status to closed if not a spare" do
        frame.roll_one_val = 5
        frame.save
        player.frames << frame        
        subject
        frame.reload
        expect(frame.status).to eq "closed"
      end 

      it "should change status to pending if spare" do
        frame.roll_one_val = 6
        player.frames << frame        
        subject
        frame.reload
        expect(player.frames.last.status).to eq "pending"
      end

      it "should not allow a second roll higher than the first" do
        frame.roll_one_val = 9
        player.frames << frame        
        subject
        frame.reload
        expect(player.frames.last.roll_two_val).to eq nil
      end   
    end

    context "third roll" do

      it "should add a bonus roll if first two rolls of frame 10 equal 10" do
        frame.update_attributes(frame_number: 10, roll_one_val: 9, roll_two_val: 1)
        player.frames << frame
        subject
        expect(player.frames.last.roll_three_val).to eq 4
      end

      it "should not add a bonus roll if not frame 10" do
        frame.update_attributes(roll_one_val: 9, roll_two_val: 1)
        player.frames << frame
        subject
        expect(player.frames.last.roll_three_val).to be_nil
      end
    end
  end
end