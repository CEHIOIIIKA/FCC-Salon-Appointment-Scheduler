#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]] #for service messages
  then
    echo $1
  fi

  echo -e "Welcome! How can we help you?"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] #check for numeric input
  then
    MAIN_MENU "Sorry, type a number of a service, please!"
  else
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed -E 's/^ +//') #check service existence
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      MAIN_MENU "Sorry, selected service is not right, try again."
    else
      echo -e "\nWhat is your phone number?" #ask customer's phone
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^ +//')
      
      if [[ -z $CUSTOMER_NAME ]] #check for new customer
      then
        echo -e "\nYou are our new customer, we are grateful for your choice. What is your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") #adding customer's name to base
      fi

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      echo -e "\nWhich time would you appoint $SERVICE_NAME_SELECTED?"
      read SERVICE_TIME
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      if [[ $INSERT_APPOINTMENT=="INSERT 0 1" ]]
      then
        echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
      else
        MAIN_MENU "Something went wrong, try again."
      fi
    fi
  fi
}

MAIN_MENU