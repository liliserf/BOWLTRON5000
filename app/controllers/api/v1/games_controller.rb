class Api::V1::GamesController < ApplicationController
  respond_to :json

  # Creates a new game resource with associated player resources based on game params.
  # Returns the game and player resources or the errors and appropriate statuses.
  # PUT /api/v1/players/{id}
  def create
    game = Game.new(game_params)
    players = game.players

    if game.save
      render json: { game: game, players: players }, status: 201
    else
      render json: { errors: game.errors }, status: 422
    end
  end

  private

  def game_params
    params.require(:game).permit(players_attributes: [:id, :name])
  end
end
