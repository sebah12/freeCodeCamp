#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Beauty Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get services
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
  
  # display list of services
  echo -e "\nList of services:"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # read user input for service
  echo -e "\nWich service would you like to reserve?"
  read SERVICE_ID_SELECTED

  # if service not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please enter a valid service number"
  else
    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

    # if service doesn't exist
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "Please enter a valid service number"
    else
      # get customer phone  
      echo -e "\nPlease enter your phone number"
      read CUSTOMER_PHONE
      
      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

      # if new customer
      if [[ -z $CUSTOMER_ID ]]
      then
        # get customer name
        echo -e "\nYou are not registered. What's your name?"
        read CUSTOMER_NAME

        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")

        # get customer id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      else
        # get customer name
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
      fi

      # get appointment time
      echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # TODO: check for time format

      # insert appointment into table
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

      # if appointment added successfully
      if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
      then
        echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      else
        # if error return to main menu
        MAIN_MENU "An error occurred while making the appointment."
      fi
    fi 
  fi   
}

MAIN_MENU
