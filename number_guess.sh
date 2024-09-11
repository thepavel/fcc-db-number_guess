#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_TO_GUESS=$RANDOM

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
      echo "$USER_GUESS ? $NUMBER_TO_GUESS"
      # game ends at some point, uncomment below and delete this line:
      # GAME_FINISHED=true
    else # not valid input
      echo That is not an integer, guess again:
    fi
  
fi