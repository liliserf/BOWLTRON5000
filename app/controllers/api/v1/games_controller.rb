class Api::V1::GamesController < ApplicationController
  respond_to :json

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
