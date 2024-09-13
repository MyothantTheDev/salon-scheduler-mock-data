#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Welcome to My Salon, how can I help you?" 
  fi

  # GET SERVICES
  echo "$($PSQL "SELECT * FROM services")" | while read ID BAR SERVICE
  do
    echo "$ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5] ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    APPOINTMENTS $SERVICE_ID_SELECTED
  fi
}

APPOINTMENTS() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1 ")
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #GET CUSTOMER
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    # CREATE NEW CUSTOMER
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    if [[ $INSERT_CUSTOMER_RESULT ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
  fi
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $1, '$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME." | sed 's/  / /g'
  fi
}

MAIN_MENU
