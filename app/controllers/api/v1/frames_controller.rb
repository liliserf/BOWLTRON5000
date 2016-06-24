class Api::V1::FramesController < ApplicationController

  # POST /api/v1/frames
  def create
    frame = FrameService.new(frame_params)
    frame
  end

  def update
    roll = RollService.new(roll_params)
  end

  def frame_params
    params.require(:frame).permit(:player_id, :pins_down)
  end
end
