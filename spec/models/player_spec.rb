require 'rails_helper'

RSpec.describe Player, type: :model do

  it { should respond_to(:name) }
  it { should respond_to(:running_total) }
  it { should belong_to(:game) }
  it { should have_many(:frames) }
  
end
