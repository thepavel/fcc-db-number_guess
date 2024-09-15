#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MIN=1
MAX=1000
SECRET_NUMBER=$(($RANDOM%($MAX-$MIN+1)+$MIN))

echo Enter your username:
read USERNAME

if [[ -z $USERNAME ]]
then
  exit
else 
  # TODO validate input
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  
  if [[ -z $USER_ID ]]
  then 
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME') RETURNING user_id" )
    
    USER_ID=$( echo $INSERT_USER_RESULT | sed -E 's/^([0-9]+).*$/\1/' )
  else    

    GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id = $USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USER_ID")
    
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  
  GAME_FINISHED=false
  GUESSES=0
  
  while [[ "$GAME_FINISHED" != "true" ]] ; do
    echo "Guess the secret number between 1 and 1000:"
    read USER_GUESS
    GUESSES=$(( $GUESSES + 1 ))
    GUESSED_NUMBER=$( echo $USER_GUESS | sed 's/[^0-9]*//g')

    if [ $GUESSED_NUMBER -eq $SECRET_NUMBER ]
    then
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES) RETURNING game_id" )
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      exit
    else 
      
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
