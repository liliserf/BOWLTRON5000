# BOWLTRON5000 API

## Installation 
Uses Ruby 2.3.1, Rails 4.2.6, SQLite 9.5.3 as database and kaminari gem for pagination.
 1. git clone project `git clone git@github.com:liliserf/bowltron5000.git`
 3. cd into project `cd bowltron5000`
 4. run `bundle install`

## Setup
 1. Run `rake db:setup`
 2. Start the rails server with `rails s` from the terminal

## Endpoints

### CREATE 
Name | Method | Description
--- | --- | ---
/api/v1/games | POST | Creates a new game with associated players

#### Sample request:
```shell
# Command Line

# Single player
curl -i -X POST -d 'game[players_attributes][][name]=Lili' http://localhost:3000/api/v1/games

# Multiple players
curl -i -X POST -d 'game[players_attributes][][name]=Beyonce&game[players_attributes][][name]=JayZ' http://localhost:3000/api/v1/games
```

#### Sample response:
```
{
  "game": {
    "id": 8,
    "created_at": "2016-06-24T21:23:50.094Z",
    "updated_at": "2016-06-24T21:23:50.094Z"
  },
  "players": [
    {
      "id": 9,
      "name": "Beyonce",
      "game_id": 8,
      "running_total": 0,
      "created_at": "2016-06-24T21:23:50.096Z",
      "updated_at": "2016-06-24T21:23:50.096Z"
    },
    {
      "id": 10,
      "name": "JayZ",
      "game_id": 8,
      "running_total": 0,
      "created_at": "2016-06-24T21:23:50.097Z",
      "updated_at": "2016-06-24T21:23:50.097Z"
    }
  ]
}
```
- Request returns errors when unable to create records.

### UPDATE

Name | Method | Parameter | Description
--- | --- | --- | ---
/api/v1/players/{id}  | PUT | pins_down | Updates the player's game with the number of pins knocked down

- Request handles logic of finding the current frame or creating the new frame, scoring the current and previous frames, and calculating the current total score for the player. 
- Returns player and frame data.

#### Sample request:
```shell

# Command Line
curl -i -X PUT -d 'players[pins_down]=10' http://localhost:3000/api/v1/players/3
```

#### Sample response:
```
{
  "player": {
    "id": 8,
    "name": "JayZ",
    "game_id": 7,
    "running_total": 0,
    "created_at": "2016-06-24T21:21:57.521Z",
    "updated_at": "2016-06-24T21:21:57.521Z"
  },
  "frame": {
    "id": 31,
    "frame_number": 1,
    "score": 0,
    "player_id": 8,
    "created_at": "2016-06-24T21:27:32.007Z",
    "updated_at": "2016-06-24T21:27:32.033Z",
    "roll_one_val": 0,
    "roll_two_val": null,
    "roll_three_val": null,
    "status": "open"
  }
}
```

- Request returns errors with detailed descriptions of why request failed.
Validates for valid roll amount and maximum number of frames when creating a new frame.



### Testing
The tests are written using RSpec. To run the test suite, call `bundle exec rspec` from the command line.
