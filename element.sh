# !/bin/bash

# check if argument is provided
if [[ -z "$1" ]]  # if no arg provided
then  # give feedback and exit
  echo "Please provide an element as an argument."
else  # retrieve the element's info, properties and type from db

  # variable used for querying the db
  PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

  # save argument in a variable
  arg=$1

  # if arg is numeric
  if [[ "$arg" =~ ^[0-9]+$ ]]
  then  # assign the column variable to atomic_number
    column="atomic_number"
  # else if arg is 1-2 characters
  elif [[ "$arg" =~ ^[A-Za-z]{1,2}$ ]]
  then  # assign the column variable to symbol
    column="symbol"
  else  # assign the column variable to name
    column="name"
  fi
  
  # check if element info exists based on determined column in elements table
  ELEMENT_INFO_EXISTS=$($PSQL "
    SELECT EXISTS(
      SELECT 1 FROM elements
      WHERE $column = '$arg'
    )
  ")

  # if element info does not exist
  if [[ "$ELEMENT_INFO_EXISTS" != "t" ]]
  then  # give feedback and exit
    echo "I could not find that element in the database."
  else  # fetch and display element details

    # fetch element info based on determined column in elements table
    ELEMENT_INFO=$($PSQL "
      SELECT atomic_number, symbol, name
      FROM elements
      WHERE $column = '$arg'
    ")

    # save element info into respective variables
    IFS="|" read ATOMIC_NUMBER SYMBOL NAME <<< "$ELEMENT_INFO"

    # fetch element properties based on determined atomic_number
    ELEMENT_PROPERTIES=$($PSQL "
      SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id
      FROM properties
      WHERE atomic_number = '$ATOMIC_NUMBER'
    ")

    # save element properties into respective variables
    IFS="|" read ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID <<< "$ELEMENT_PROPERTIES"

    # fetch element type based on type_id
    TYPE=$($PSQL "
      SELECT type 
      FROM types 
      WHERE type_id = '$TYPE_ID'
    ")

    # output the respective information about the specific element
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  
  fi
fi