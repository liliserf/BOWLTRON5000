class Api::V1::FramesController < ApplicationController

  def create
    frame = FrameService.new(frame_params)
  end

  def update
    roll = RollService.new(roll_params)
  end
end
