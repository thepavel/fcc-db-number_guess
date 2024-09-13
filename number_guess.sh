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
    if [[ $INSERT_USER_RESULT != "1|0" ]]
    then 
      echo $INSERT_USER_RESULT
    fi

    USER_ID=$($PSQL "SELECT users.user_id FROM users WHERE username = '$USERNAME'")
    echo $USER_ID
  else
    echo "$USER_ID"
    # get games data
    # "SELECT COUNT(game_id) AS games_playes, MIN(guesses) as best_game"
    echo "Welcome back, $USERNAME! You have played <games_played> games, and your best game took <best_game> guesses."
  fi

  GAME_FINISHED=false
  GUESSES=0
  echo "Guess the secret number between 1 and 1000:"
    
  # Create game here:
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, 1)")

  while [[ "$GAME_FINISHED" != "true" ]] ; do
    read USER_GUESS
    GUESSES=$(( $GUESSES + 1 ))
    
    echo "$USER_ID guessed $USER_GUESS. there have been $GUESSES guesses to reach $SECRET_NUMBER"

    if [ $USER_GUESS -eq $SECRET_NUMBER ]
    then
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      GAME_FINISHED=true
      exit
    else 
      if [ $USER_GUESS -lt $SECRET_NUMBER ]
      then
        echo "It's higher than that, guess again:"
      else 
        if [ $USER_GUESS -gt $SECRET_NUMBER ]
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
