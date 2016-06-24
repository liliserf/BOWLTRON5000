require 'rails_helper'

RSpec.describe Api::V1::PlayersController, type: :controller do
  describe "POST #update" do
    let!(:player) do
      Game.create(players_attributes: [{ name: "lili" }]).players.last
    end

    context "successfully updates a player" do
      subject { put :update, { players: { pins_down: 4 }, id: player.id } }
      
      it "renders json for updated player and frame records" do
        subject
        res = JSON.parse(response.body)
        expect(res["player"]["id"]).to eq 1
        expect(res["player"]["running_total"]).to eq 4
        expect(response.status).to eq 201
      end
    end

    context "fails with invalid request" do
      context "player id does not exist" do
        subject { put :update, { players: { pins_down: 4 }, id: 2 } }
        it "renders response with errors" do
          subject
          res = JSON.parse(response.body)
          expect(res).to have_key("errors")
          expect(response.status).to eq 422
        end

        it "renders errors response with reason for failure" do
          subject
          res = JSON.parse(response.body)
          expect(res["errors"]).to eq "Couldn't find Player with 'id'=2"
        end
      end

      context "invalid roll" do
        subject { put :update, { players: { pins_down: 12 }, id: 1 } }

        it "renders response with errors" do
          subject
          res = JSON.parse(response.body)
          expect(res).to have_key("errors")
          expect(response.status).to eq 422
        end

        it "renders response with errors" do
          subject
          res = JSON.parse(response.body)
          expect(res["errors"]).to eq "invalid pin count"
        end
      end

      context "too many frames" do
        let!(:ten_frames) do
          frames = []
          frame = 0
          while frame < 10 do
            f = Frame.create(
              frame_number: frame + 1,
              status: "closed", 
              player: player)
            frame += 1
          end
        end
        subject { put :update, { players: { pins_down: 4 }, id: player.id } }
        it "does not create an 11th frame" do
          player.reload
          subject
          res = JSON.parse(response.body)
          expect(res["errors"]).to eq "frame limit has been reached"        
        end
      end
    end
  end
end
