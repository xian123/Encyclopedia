#!/bin/bash

# Count the number of occurrences of a char in a string using Bash

count_number_occurrences()
{
    string=$1
    char=$2
    # Split the string by $char and print the number of resulting fields minus 1.
    echo $(echo "${string}" | awk -F"${char}" '{print NF-1}')
}

string="00:00:00:00:00:00"
char=":"
num=$(count_number_occurrences $string $char)
echo -e "There are $num $char in $string \n"


string="11,11,11"
char=","
num=$(count_number_occurrences $string $char)
echo -e "There are $num $char in $string \n"
