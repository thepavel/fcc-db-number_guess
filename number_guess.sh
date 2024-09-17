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
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 1) RETURNING user_id" )
    
    USER_ID=$( echo $INSERT_USER_RESULT | sed -E 's/^([0-9]+).*$/\1/' )
  else   
    # update games played
    UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")
    
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
    USER_INFO=($PSQL "SELECT games_played, best_game FROM users WHERE user_id = $USER_ID")
    echo "Welcome back, ${USERNAME}! You have played ${USER_INFO[0]} games, and your best game took ${USER_INFO[1]} guesses."
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  
  GAME_FINISHED=false
  GUESSES=0
  echo "Guess the secret number between 1 and 1000:"

  while [[ "$GAME_FINISHED" != "true" ]] ; do
    
    read USER_GUESS
    GUESSES=$(( $GUESSES + 1 ))
    GUESSED_NUMBER=$( echo $USER_GUESS | sed 's/[^0-9]*//g')

    if [ $GUESSED_NUMBER -eq $SECRET_NUMBER ]
    then
      echo $GUESSES
      echo $BEST_GAME
      # if [ $GUESSES -lt $BEST_GAME ] 
      # then 
      #   $( $PSQL "UPDATE users SET best_game = $BEST_GAME WHERE user_id = $USER_ID" )
      # fi
      
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
fi
