#!/bin/bash

random_string()
{
    cat /dev/urandom | tr -dc ${1:-'a-zA-Z0-9'} | fold -w ${2:-32} | head -n 1
}

echo "Generate a random string by default(length:32, type:alphanumeric)."
random_string

echo -e "\nGenerate a random string(length:16, type:lowercase)."
random_string 'a-z' 16

echo -e "\nGenerate a random string(length:16, type:uppercase)."
random_string 'A-Z' 16

echo -e "\nGenerate a random string(length:3, type:numeric)."
random_string '0-9' 3
