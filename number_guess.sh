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
  USER_INFO=$($PSQL "SELECT user_id, name, games_played, best_game FROM users WHERE name = '$USERNAME'")
  GAME_FINISHED=false
  GUESSES=0
  
  # TODO validate input
  if [[ -z $USER_INFO ]]
  then
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
    
    USER_INFO=$($PSQL "SELECT user_id, name, games_played, best_game FROM users WHERE name = '$USERNAME'")
    USER_INFO_ARRAY=( $( echo $USER_INFO | sed -E 's/\|/\ /g' ) )

    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else   
    USER_INFO_ARRAY=( $( echo $USER_INFO | sed -E 's/\|/\ /g' ) )
    echo "Welcome back, $USERNAME! You have played ${USER_INFO_ARRAY[2]} games, and your best game took ${USER_INFO_ARRAY[3]} guesses."
  fi

  USER_ID=${USER_INFO_ARRAY[0]}
  GAMES_PLAYED=${USER_INFO_ARRAY[2]}
  BEST_GAME=${USER_INFO_ARRAY[3]}

  echo "Guess the secret number between 1 and 1000:"

  while [[ "$GAME_FINISHED" != "true" ]] ; do
    read USER_GUESS
    
    if ! [[ $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      continue
    else
      ((++GUESSES))

      if [ $USER_GUESS -lt $SECRET_NUMBER ] ; then
        echo "It's higher than that, guess again:"
      else if [ $USER_GUESS -gt $SECRET_NUMBER ] ; then
          echo "It's lower than that, guess again:"
      else if [ $USER_GUESS -eq $SECRET_NUMBER ] ; then
            GAME_FINISHED=true

            if [[ -z $BEST_GAME ]] ; then # new users look like this -- they don't have a best game
              BEST_GAME=$GUESSES
              GAMES_PLAYED=1
            else 
              BEST_GAME=$(($GUESSES < $BEST_GAME ? $GUESSES : $BEST_GAME))
              ((++GAMES_PLAYED))
            fi
            
            UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE user_id = $USER_ID")
            
            echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"      
          fi 
        fi
      fi
    fi
  done
fi
