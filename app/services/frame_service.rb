class FrameService
  attr_accessor :player, :frame, :pins_down

  # Initializes with Player id and the number of pins knocked down in this roll
  def initialize(player_id:, pins_down:)
    @player = Player.find(player_id)
    @pins_down = pins_down.to_i
  end

  # Does basic check to see if roll is valid without context and returns an error if not
  # Checks to see if final frame was created and returns an error if attempt to exceed limit
  # Calls the roll updating service
  def update_player_frames!
    return invalid_pins if invalid_pins_down?
    return frame_limit_error if find_or_create_current_frame.id.nil? 
    update_roll!
  end

  private

  # If the roll isn't mid frame, it adds a frame and returns the frame
  def find_or_create_current_frame
    add_frame unless find_current_frame
    @frame
  end

  # Current frame is a status of open or in the final frame waiting 
  # on bonus roll
  def find_current_frame
    if open_frame? || final_frame_with_bonus?
      @frame = player.frames.last
    end
    @frame
  end

  # Builds a new frame associated with player.
  # If the player already has 10 frames, it destroys the record and to return an error
  # If the game is already under way, it increments the frame by 1
  # If this is the first frame, it starts the game with a new frame.
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

  # Checks the previous frame number and adds one for the current frame
  def increment_frame_number
    previous_frame_number = player.frames.last.frame_number
    @frame.frame_number = previous_frame_number + 1
    @frame if @frame.save
  end

  # Check that the current frame is still in progress
  def open_frame?
    player.frames.last && player.frames.last.open?
  end

  # Checks to see if it's a final frame awaiting additional rolls
  def final_frame_with_bonus?
    player.frames.last && 
    player.frames.last.frame_number == 10 && 
    player.frames.last.pending?
  end

  # Basic check for valid roll 0-10
  def invalid_pins_down?
    pins_down > 10 || pins_down < 0
  end

  # Error output for invalid roll
  def invalid_pins
    { errors: "invalid pin count" }
  end

  # Checks for final frame
  def frame_limit_reached
    player.frames.count == 10
  end
  
  # Error output for trying to add another frame after 10 frames
  def frame_limit_error
    return { errors: "frame limit has been reached" }
  end

  # Creates the roll service and calls the method to update the player's new roll
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