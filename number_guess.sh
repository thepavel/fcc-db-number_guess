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

  USER_ID=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

  if [[ -z $USER_ID ]]
  then 
    # create new user with entered username
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else

    echo "Welcome back, $USERNAME! You have played <games_played> games, and your best game took <best_game> guesses."
  fi

  GAME_FINISHED=false
  echo "Guess the secret number between 1 and 1000:"
  
  # todo: loop
    read USER_GUESS
    if [[ $USER_GUESS =~ ^[0-9]{1,4}$ ]] # should be 1-1000, no more than 4 digits needed
    then
      # check against random number and tell user if higher or lower
      echo "$USER_GUESS ? $SECRET_NUMBER"
      # game ends at some point, uncomment below and delete this line:
      # GAME_FINISHED=true
    else # not valid input
      echo That is not an integer, guess again:
    fi
  
fi