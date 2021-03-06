require 'rails_helper'

RSpec.describe ScoringService do
  
  let!(:game) do
    Game.create(players_attributes: [{ name: "Bob" }])
  end

  let(:player) do
    game.players.first
  end

  let(:scoring_svc) do
    ScoringService.new(player)
  end

  let(:frame) do
    Frame.create(frame_number: 1, roll_one_val: 5, player: player)
  end

  let(:ten_frames) do
    frames = []
    frame = 0
    while frame < 10 do
      f = Frame.create(frame_number: frame + 1,
        roll_one_val: 4,
        roll_two_val: 4,
        status: "closed",
        score: 8
      )
      frame += 1
      frames << f
    end
    frames
  end

  subject { scoring_svc.score! }

  describe "#score_current_frame" do
    context "normal frames" do
      it "should set the first roll to frame score on first roll" do
        player.frames << frame
        subject
        expect(frame.score).to eq 5
      end

      it "should add the second roll to frame score" do
        frame.update_attributes(score: 5, roll_two_val: 3, status: "closed")
        player.frames << frame
        subject
        expect(frame.score).to eq 8
      end
    end

    context "final frame" do
      context "regular rolls" do
        let!(:final_frame) do
          Frame.create(frame_number: 10, roll_one_val: 6, status: "open")
        end
        it "should set the first roll to frame score on first roll" do
          player.frames << final_frame
          subject
          expect(final_frame.score).to eq 6
        end

        it "should add the second roll to the frame score" do
          final_frame.update_attributes(score: 6, roll_two_val: 2, status: "open")
          player.frames << final_frame
          subject
          expect(final_frame.score).to eq 8
        end
      end
    end

    context "spare" do
      let!(:final_frame) do
        Frame.create(frame_number: 10, roll_one_val: 6, status: "open")
      end
      it "should add the second roll to the frame score" do
        final_frame.update_attributes(score: 6, roll_one_val: 6, roll_two_val: 4, status: "pending")
        player.frames << final_frame
        subject
        expect(final_frame.score).to eq 10
        expect(final_frame.status).to eq "pending"
      end

      it "should add the bonus roll to the frame score" do
        final_frame.update_attributes(score: 10, roll_one_val: 6, roll_two_val: 4, roll_three_val: 6, status: "pending")
        player.frames << final_frame
        player.reload
        subject
        final_frame.reload
        expect(final_frame.score).to eq 16
        expect(final_frame.status).to eq "closed"
      end
    end

    context "strike" do
      context "followed by regular roll" do
        let!(:final_frame) do
          Frame.create(frame_number: 10, roll_one_val: 10, status: "pending")
        end

        it "should add the second roll to the frame score" do
          final_frame.update_attributes(score: 10, roll_two_val: 4, status: "pending")
          player.frames << final_frame
          subject
          expect(final_frame.score).to eq 14
          expect(final_frame.status).to eq "pending"
        end

        it "should add the third roll to the frame score" do
          final_frame.update_attributes(
            score: 14, 
            roll_one_val: 10, 
            roll_two_val: 4, 
            roll_three_val: 6, 
            status: "pending"
          )
          player.frames << final_frame
          subject
          expect(final_frame.score).to eq 20
          expect(final_frame.status).to eq "closed"
        end
      end
    end
  end

  describe "#update_previous_frames" do

    context "spare rolled in previous frame" do
      let!(:spare_frame) do
          Frame.create(frame_number: 1, roll_one_val: 6, roll_two_val: 4, score: 10, status: "pending")
      end

      it "adds roll one to previous frame and updates status" do
        current_frame = Frame.create(frame_number: 2, roll_one_val: 7)
        player.frames << [spare_frame, current_frame]
        subject
        expect(current_frame.score).to eq 7
        expect(spare_frame.score).to eq 17
        expect(spare_frame.status).to eq "closed"
      end
    end

    context "Strike rolled in previous frame" do
      context "followed by regular frame" do

        let!(:strike_frame) do
          Frame.create(frame_number: 1, roll_one_val: 10, score: 10, status: "pending")
        end

        it "adds the first roll of current frame to the previous strike frame" do
          current_frame = Frame.create(frame_number: 2, roll_one_val: 7)
          player.frames << [strike_frame, current_frame]
          subject
          expect(current_frame.score).to eq 7
          expect(strike_frame.score).to eq 17
        end

        it "adds the second roll of current frame to the previous strike frame" do
          current_frame = Frame.create(frame_number: 2, roll_one_val: 7, roll_two_val: 2, score: 7, status: "closed")
          strike_frame.score = 17
          strike_frame.save
          player.frames << [strike_frame, current_frame]
          subject
          expect(current_frame.score).to eq 9
          expect(strike_frame.score).to eq 19
          expect(strike_frame.status).to eq "closed"
        end
      end

      context "followed by a spare frame" do
        let!(:strike_frame) do
          Frame.create(frame_number: 1, roll_one_val: 10, score: 10, status: "pending")
        end

        it "adds the first roll of current frame to the previous strike frame" do
          current_frame = Frame.create(frame_number: 2, roll_one_val: 7)
          player.frames << [strike_frame, current_frame]
          subject
          expect(current_frame.score).to eq 7
          expect(strike_frame.score).to eq 17
        end

        it "adds the second roll of current frame to the previous strike frame" do
          current_frame = Frame.create(frame_number: 2, roll_one_val: 7, roll_two_val: 3, score: 7, status: "pending")
          strike_frame.score = 17
          strike_frame.save
          player.frames << [strike_frame, current_frame]
          subject
          expect(current_frame.score).to eq 10
          expect(strike_frame.score).to eq 20
          expect(strike_frame.status).to eq "closed"
        end
      end

      context "followed by one strike frame" do

        let!(:strike_frame) do
          Frame.create(frame_number: 1, roll_one_val: 10, score: 10, status: "pending")
        end

        it "adds the first strike of current frame to the previous strike frame" do
          current_frame = Frame.create(frame_number: 2, roll_one_val: 10, score: 10, status: "pending")
          player.frames << [strike_frame, current_frame]
          subject
          expect(current_frame.score).to eq 10
          expect(strike_frame.score).to eq 20
          expect(strike_frame.status).to eq "pending"

        end

        it "adds the second roll of current frame to the previous strike frame" do
          current_frame = Frame.create(frame_number: 2, roll_one_val: 7, roll_two_val: 2, score: 7, status: "closed")
          strike_frame.score = 17
          strike_frame.save
          player.frames << [strike_frame, current_frame]
          subject
          expect(current_frame.score).to eq 9
          expect(strike_frame.score).to eq 19
          expect(strike_frame.status).to eq "closed"
        end
      end
      context "followed by two strike frames" do

        let!(:strike_frame_one) do
          Frame.create(frame_number: 1, roll_one_val: 10, score: 20, status: "pending")
        end

        let!(:strike_frame_two) do
          Frame.create(frame_number: 2, roll_one_val: 10, score: 10, status: "pending")
        end

        let!(:current_frame) do 
          Frame.create(frame_number: 3, roll_one_val: 10, status: "pending")
        end

        it "adds the strike of current frame to previous two frames" do
          player.frames << [strike_frame_one, strike_frame_two, current_frame]
          subject
          expect(current_frame.score).to eq 10
          expect(strike_frame_two.score).to eq 20
          expect(strike_frame_one.score).to eq 30
          expect(strike_frame_one.status).to eq "closed"
          expect(strike_frame_two.status).to eq "pending"
          expect(current_frame.status).to eq "pending"
        end
      end
    end
  end

  describe "#update_running_total" do
    let!(:frame_one) do
      Frame.create(frame_number: 1, roll_one_val: 5, roll_two_val: 4, score: 9, status: "closed")
    end

    let!(:frame_two) do
      Frame.create(frame_number: 2, roll_one_val: 5, roll_two_val: 4, score: 9, status: "closed")
    end

    let!(:frame_three) do
      Frame.create(frame_number: 3, roll_one_val: 5, status: "open")
    end

    context "regular frames" do
      it "adds all the scores for including incomplete frames" do
        player.frames << [frame_one, frame_two, frame_three]
        subject
        expect(player.running_total).to eq 23
      end

      it "adds all the scores including incomplete frames" do
        frame_three.score = 5
        frame_three.roll_two_val = 3
        frame_three.status = "closed"
        frame_three.save
        player.frames << [frame_one, frame_two, frame_three]
        subject
        expect(player.running_total).to eq 26
      end

      it "scores all 10 regular frames" do
        player.frames << ten_frames
        allow_any_instance_of(ScoringService).to receive(:score_current_frame).and_return(true)
        subject
        expect(player.running_total).to eq 80
      end
    end

    context "spares" do
      let!(:frame_one) do
        Frame.create(frame_number: 1, roll_one_val: 4, roll_two_val: 6, score: 10, status: "pending")
      end

      let!(:frame_two) do
        Frame.create(frame_number: 2, roll_one_val: 3)
      end

      it "adds the first roll of the next frame to the frame score" do
        player.frames << [frame_one, frame_two]
        subject
        expect(player.running_total).to eq 16
      end
    end

    context "strikes" do
      let!(:frame_one) do
        Frame.create(frame_number: 1, roll_one_val: 10, score: 10, status: "pending")
      end   

      let!(:frame_two) do 
        Frame.create(frame_number: 2, roll_one_val: 3)      
      end

        let!(:strike_frame_one) do
          Frame.create(frame_number: 1, roll_one_val: 10, score: 20, status: "pending")
        end

        let!(:strike_frame_two) do
          Frame.create(frame_number: 2, roll_one_val: 10, score: 10, status: "pending")
        end

        let!(:current_frame) do 
          Frame.create(frame_number: 3, roll_one_val: 10, status: "pending")
        end

      it "adds current score with one extra non-strike rolls" do
        player.frames << [frame_one, frame_two]
        subject
        expect(player.running_total).to eq 16
      end

      it "adds current score with 2 extra non-strike rolls" do
        player.frames << [frame_one, frame_two]
        frame_one.update_attributes(score: 13)
        frame_two.update_attributes(roll_two_val: 6, status: "closed", score: 3)
        subject
        expect(player.running_total).to eq 28
      end

      it "scores running_total for three consecutive strikes" do        
        player.frames << [strike_frame_one, strike_frame_two, current_frame]
        subject
        expect(player.running_total).to eq 60
      end
    end
  end
end