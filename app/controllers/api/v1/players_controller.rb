class Api::V1::PlayersController < ApplicationController

  # # POST /api/v1/players
  # def create
  #   frame_svc = FrameService.new(player_id: frame_params[:player_id])
  #   new_frame = frame_svc.update_player_frame!
  #   if new_frame[:errors]
  #     render json: new_frame, status: 422
  #   else
  #     render json: { frame: frame }, status: 201
  #   end
  # end

  # PUT only to update existing player id

  # PUT /api/v1/players/{id}
  def update
    frame_svc = FrameService.new(player_id: frame_params[:player_id])

    update_frame = roll_svc.add_roll!

    if update_frame[:errors]
      render json: new_frame, status: 422
    else
      # render json: { frame: frame, player: player }, status 201
    end
  end

  def frame_params
    params.require(:frame).permit(:player_id, :pins_down)
  end
end
