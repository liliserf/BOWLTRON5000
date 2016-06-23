require 'rails_helper'

RSpec.describe Frame, type: :model do
  it { should respond_to(:score) }
  it { should respond_to(:frame_number) }
  it { should belong_to(:player) }

end
