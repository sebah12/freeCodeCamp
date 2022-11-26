#!/bin/bash

# connect to database
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

# generate random number
RANDOM=$(date +%s%N | cut -b10-19)
RAND=$(( $RANDOM % 1000 + 1 ))

#variable to count user attempts
ATTEMPTS=0

# guess number game
GUESS_NUMBER() { 
  # check for number
  read USER_GUESS
  # if guess not a number
  while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read USER_GUESS
  done
  # increment attempts
  ((ATTEMPTS++))
  # if guess is correct
  if [[ $(($USER_GUESS)) == $RAND ]]
  then
    echo "You guessed it in $(echo $ATTEMPTS) tries. The secret number was $(echo $RAND). Nice job!"
  else
    if [[ $(($USER_GUESS)) -lt $RAND ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
    GUESS_NUMBER
  fi
}

# prompt user for username
echo "Enter your username:"
read USERNAME
#TODO: check for username MAX LENGTH
# get user data from DB
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_name = '$USERNAME';")
# if user not found
if [[ -z $GAMES_PLAYED ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # insert user in DB 
  NEW_USER_RESULT=$($PSQL "INSERT INTO users (user_name) VALUES ('$USERNAME');")
  # TODO Check for succesfull insertion
else  
  # Welcome returning user
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_name = '$USERNAME';")
  echo "Welcome back, $USERNAME! You have played $(echo $(($GAMES_PLAYED))) games, and your best game took $(echo $(($BEST_GAME))) guesses."
fi
# start GAME
echo "Guess the secret number between 1 and 1000:"
GUESS_NUMBER
# update user games played in DB
UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_name = '$USERNAME';")
# update new best game in DB
if [[ -z $BEST_GAME ]]
then
  UPDATE_RESULT=$($PSQL "UPDATE users SET best_game = $ATTEMPTS WHERE user_name = '$USERNAME';")
else
  if [[ $ATTEMPTS -lt $(($BEST_GAME)) ]]
  then
    UPDATE_RESULT=$($PSQL "UPDATE users SET best_game = $ATTEMPTS WHERE user_name = '$USERNAME';")
  fi
fi
