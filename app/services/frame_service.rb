class FrameService
  attr_accessor :player, :frame, :pins_down

  def initialize(player_id:, pins_down:)
    @player = Player.find(player_id)
    @pins_down = pins_down.to_i
  end

  def update_player_frames!
    return invalid_pins if invalid_pins_down?
    return frame_limit_error if find_or_create_current_frame.id.nil? 
    update_roll!
  end

  private

  def find_or_create_current_frame
    add_frame unless find_current_frame
    @frame
  end

  def find_current_frame
    if open_frame? || final_frame_with_bonus?
      @frame = player.frames.last
    end
    @frame
  end

  def add_frame
    @frame = Frame.new(player: player)
    if player.frames.count == 10
      @frame.destroy
    elsif player.frames.count >= 1
      increment_frame_number
    else
      @frame.frame_number = 1
      @frame if @frame.save
    end
  end

  def increment_frame_number
    previous_frame_number = player.frames.last.frame_number
    @frame.frame_number = previous_frame_number + 1
    @frame if @frame.save
  end

  def open_frame?
    player.frames.last && player.frames.last.open?
  end

  def final_frame_with_bonus?
    player.frames.last && 
    player.frames.last.frame_number == 10 && 
    player.frames.last.pending?
  end

  def invalid_pins_down?
    pins_down > 10 || pins_down < 0
  end

  def invalid_pins
    { errors: "invalid pin count" }
  end

  def frame_limit_error
    return { errors: "frame limit has been reached" }
  end

  def frame_limit_reached
    player.frames.count == 10
  end

  def update_roll!
    player.reload
    roll_svc = RollService.new(
      player: player,
      pins_down: pins_down,
      frame: player.frames.last
    )
    roll_svc.add_roll!
  end
end