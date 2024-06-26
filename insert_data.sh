#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#akotchifo_mick project 2
echo $($PSQL "TRUNCATE games, teams")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_G OPPONENT_G; do
  if [[ $YEAR != 'year' ]]; then
    #first get winner id
    WINNER_ID=$($PSQL "select team_id as winner_id from teams where name='$WINNER'")
    OPPONENT_ID=$($PSQL "select team_id as opponent_id from teams where name='$OPPONENT'")
    #if winner not found
    if [[ -z $WINNER_ID ]]; then
      #set to null
      WINNER_ID=null
      #insert winner
      INSERT_WINNER=$($PSQL "insert into teams(name) values('$WINNER')")
      if [[ $INSERT_WINNER == "INSERT 0 1" ]]; then
        WINNER_ID=$($PSQL "select team_id as winner_id from teams where name='$WINNER'")
        echo "Inserted into teams, $WINNER, $WINNER_ID"
      fi
    fi
    if [[ -z $OPPONENT_ID ]]; then
      #set to null
      OPPONENT_ID=null
      #insert opponent
      INSERT_OPPONENT=$($PSQL "insert into teams(name) values('$OPPONENT')")
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]; then
        OPPONENT_ID=$($PSQL "select team_id as opponent_id from teams where name='$OPPONENT'")
        echo "Inserted into teams, $OPPONENT, $OPPONENT_ID"
      fi
    fi
    #get game id
    GAME_ID=$($PSQL "select game_id from games where round='$ROUND' and year='$YEAR' and opponent_id='$OPPONENT_ID'")
    #if game not found
    if [[ -z $GAME_ID ]]; then
      #set to null
      GAME_ID=null
      #insert game
      INSERT_GAME=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_G, $OPPONENT_G)")
      if [[ $INSERT_GAME == "INSERT 0 1" ]]; then
        echo "Inserted into games, $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_G, $OPPONENT_G"
      fi
    fi
  fi
done

