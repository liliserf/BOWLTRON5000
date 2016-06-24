class Api::V1::PlayersController < ApplicationController

  # PUT /api/v1/players/{id}
  def update
    frame_svc = FrameService.new(
      player_id: params[:id], 
      pins_down: player_params[:pins_down].to_i
    )

    player = frame_svc.update_player_frames!

    if player[:errors]
      render json: player, status: 422
    else
      render json: { player: player, frame: player.frames.last }, status: 201
    end
  end

  def player_params
    params.require(:players).permit(:pins_down)
  end
end
