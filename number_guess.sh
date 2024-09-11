#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_TO_GUESS=$RANDOM

echo -e "\nEnter your username:"
read USERNAME

if [[ -z $USERNAME ]]
then
  echo Username required. Please try again.
else
  # TODO look up username

  USER_ID=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

  if [[ -z $USER_ID ]]
  then 
    # create new user with entered username
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else

    echo "Welcome back, $USERNAME! You have played <games_played> games, and your best game took <best_game> guesses."
  fi
fi