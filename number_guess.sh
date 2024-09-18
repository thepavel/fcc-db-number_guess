#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MIN=1
MAX=1000
SECRET_NUMBER=$(($RANDOM%($MAX-$MIN+1)+$MIN))

NEW_USER=false

echo Enter your username:
read USERNAME

if [[ -z $USERNAME ]]
then
  exit
else 
  # SELECT user_id, username, games_played, best_game FROM users WHERE username = 'testuser'
  USER_INFO=$($PSQL "SELECT user_id, username, games_played, best_game FROM users WHERE username = '$USERNAME'")
  # TODO validate input

  if [[ -z $USER_INFO ]]
  then 
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    $($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_INFO=$($PSQL "SELECT user_id, username, games_played, best_game FROM users WHERE username = '$USERNAME'")
  else   
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  USER_INFO_ARRAY=( $( echo $USER_INFO | sed -E 's/\|/\ /g' ) )
  USER_ID=${USER_INFO_ARRAY[1]}
  GAMES_PLAYED=${USER_INFO_ARRAY[2]}
  BEST_GAME=${USER_INFO_ARRAY[3]}
  
  GAME_FINISHED=false
  GUESSES=0
  echo "Guess the secret number between 1 and 1000:"

  while [[ "$GAME_FINISHED" != "true" ]] ; do
    
    read USER_GUESS
    GUESSES=$(( $GUESSES + 1 ))
    GUESSED_NUMBER=$( echo $USER_GUESS | sed 's/[^0-9]*//g')

    if [ $GUESSED_NUMBER -eq $SECRET_NUMBER ]
    then
      BEST_GAME=$(($GUESSES < $BEST_GAME || $BEST_GAME == 0 ? $GUESSES : $BEST_GAME))
      
      # update user
      $($PSQL "UPDATE users SET games_played = games_played + 1, best_game = $BEST_GAME WHERE user_id = $USER_ID")
      
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      
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
