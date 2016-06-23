require 'rails_helper'

RSpec.describe Api::V1::GamesController, type: :controller do
  describe "POST #create" do
    subject { post :create, { game: { players_attributes: [{ name: "Beyonce" }, { name: "JayZ" }] } } }

    context "successfully creates a new game" do
      it "renders json for created game record" do
        subject
        res = JSON.parse(response.body)
        expect(res["players"].count).to eq 2
        expect(response.status).to eq 201
      end
    end

    context "fails with invalid requests" do
      context "players_attributes collection is empty" do
        subject { post :create, { game: { players_attributes: [] } } }
        it "renders an errors json" do
          subject
          res = JSON.parse(response.body)
          expect(res).to have_key("errors")
          expect(response.status).to eq 422
        end

        it "renders errors response with reason for failure" do
          subject
          res = JSON.parse(response.body)
          expect(res["errors"]["players"]).to include "can't be blank"
        end
      end
      
      context "players_attributes name value is blank" do
        subject { post :create, { game: { players_attributes: [{name: ""}] } } }
        it "renders failure response with errors" do
          subject
          res = JSON.parse(response.body)
          expect(res["errors"]["players"]).to include "can't be blank"
          expect(response.status).to eq 422
        end
      end

      context "records for players_attributes exceeds record limit" do
        subject { post :create, { game: { players_attributes: [
          FactoryGirl.attributes_for(:player),
          FactoryGirl.attributes_for(:player),
          FactoryGirl.attributes_for(:player),
          FactoryGirl.attributes_for(:player),
          FactoryGirl.attributes_for(:player),
          FactoryGirl.attributes_for(:player),
          FactoryGirl.attributes_for(:player),
        ] } } }

        it "renders errors response with reason for failure" do
          subject
          res = JSON.parse(response.body)
          expect(res["errors"]).to eq "Maximum 6 records are allowed. Got 7 records instead."
          expect(response.status).to eq 422        
        end
      end
    end
  end
end
