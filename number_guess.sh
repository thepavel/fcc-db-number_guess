#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MIN=1
MAX=1000
SECRET_NUMBER=$(($RANDOM%($MAX-$MIN+1)+$MIN))

echo -e "\nEnter your username:"
read USERNAME

if [[ -z $USERNAME ]]
then
  echo Username required. Please try again.
else 
  # TODO validate input
  # USER_ID=$($PSQL "SELECT users.user_id, COUNT(games.game_id) AS games_played, MIN(guesses) AS best_game FROM users LEFT JOIN games USING(user_id) WHERE username = '$USERNAME' GROUP BY users.user_id")
  USER_ID=$($PSQL "SELECT users.user_id FROM users WHERE username = '$USERNAME'")
  
  if [[ -z $USER_ID ]]
  then 
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    # TODO: create new user with entered username
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    if [[ $INSERT_USER_RESULT =~ "INSERT 0 1$" ]]
    then 
      echo $INSERT_USER_RESULT
    fi
    
    USER_ID=$($PSQL "SELECT users.user_id FROM users WHERE username = '$USERNAME'")
  else
    
    # get games data
    GAMES_RESULT=$($PSQL "SELECT COUNT(game_id) AS games_played, MIN(guesses) as best_game FROM games")
    
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, 1) RETURNING game_id" )
  GAME_ID=$( echo $INSERT_GAME_RESULT | sed -E 's/^([0-9]+).*$/\1/' )

  GAME_FINISHED=false
  GUESSES=0
  echo "Guess the secret number between 1 and 1000:"

  while [[ "$GAME_FINISHED" != "true" ]] ; do
    read USER_GUESS
    GUESSES=$(( $GUESSES + 1 ))
    # updating existing game
      UPDATE_GAME_RESULT=$( $PSQL "UPDATE games SET guesses = guesses + 1 WHERE game_id = $GAME_ID" )

    echo "$USER_ID guessed $USER_GUESS. there have been $GUESSES guesses to reach $SECRET_NUMBER"

    if [ "$USER_GUESS" -eq "$SECRET_NUMBER" ]
    then
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

      GAME_FINISHED=true
      # todo update game as finished? may make stats meaningless without that.
      UPDATE_GAME_RESULT=$( $PSQL "UPDATE games SET is_completed = true WHERE game_id = $GAME_ID" )
      
    else 
      
      GUESSED_NUMBER=$( echo $USER_GUESS | sed 's/[^0-9]*//g')
      if [ $GUESSED_NUMBER -lt $SECRET_NUMBER ]
      then
        echo "It's higher than that, guess again:"
      else 
        if [ $GUESSED_NUMBER -gt $SECRET_NUMBER ]
        then
          echo "It's lower than that, guess again:"
        else 
          echo "That is not an integer, guess again:"
        fi
      fi

    fi
  done

    #   if [[ $USER_GUESS =~ ^[0-9]{1,4}$ ]] # should be 1-1000, no more than 4 digits needed
    #   then
    #     if [[ $USER_GUESS < $SECRET_NUMBER ]]
    #     then 
    #       echo "It's lower than that, guess again:"
    #     else if [[ $USER_GUESS > $SECRET_NUMBER ]]; then
    #       echo "It's higher than that, guess again:"
    #     else if [[ $USER_GUESS == $SECRET_NUMBER ]]; then
    #       echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    #       GAME_FINISHED=true
    #     else 
    #       echo "Unexpected input, guess again:"
    #     fi 
    #   else
    #     echo "That is not an integer, guess again:"
    #   fi
    # # done
fi
