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
    RollService.new(player, pins_down)
  end

  subject { roll_svc.add_roll! }

  describe "#add_roll!" do
    context "first roll" do
      it "should add roll_one to the current frame" do
        player.frames << frame
        subject
        frame.reload
        expect(frame.roll_one).to eq 4
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
        roll_svc = RollService.new(player, pins_down)
        roll_svc.add_roll!
        frame.reload
        expect(frame.roll_one).to eq 10
        expect(frame.status).to eq "pending"
      end
    end

    context "second roll" do
      it "should add roll_two to the current frame" do
        frame.roll_one = 5
        player.frames << frame
        subject
        frame.reload
        expect(player.frames.last.roll_two).to eq 4
      end

      it "should change status to closed if not a spare" do
        frame.roll_one = 5
        player.frames << frame        
        subject
        frame.reload
        expect(player.frames.last.status).to eq "closed"
      end 

      it "should change status to pending if spare" do
        frame.roll_one = 6
        player.frames << frame        
        subject
        frame.reload
        expect(player.frames.last.status).to eq "pending"
      end

      it "should not allow a second roll higher than the first" do
        frame.roll_one = 9
        player.frames << frame        
        subject
        frame.reload
        expect(player.frames.last.roll_two).to eq nil
      end   
    end

    context "third roll" do
      it "should add a bonus roll if first two rolls of frame 10 equal 10" do
        f = Frame.create(frame_number: 10)
        f.update_attributes(roll_one: 9, roll_two: 1)
        player.frames << f
        subject
        expect(player.frames.last.roll_three).to eq 4
      end

      it "should not add a bonus roll if not frame 10" do
        f = Frame.create(frame_number: 9)
        f.update_attributes(roll_one: 9, roll_two: 1)
        player.frames << f
        subject
        expect(player.frames.last.roll_three).to be_nil
      end
    end
  end
end