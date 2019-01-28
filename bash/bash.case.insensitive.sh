#!/bin/bash

# Case insensitive comparison of strings in shell script

echo "Method 1: Using BASH"
# If the bash is used, you can run the below commands in bash.
str1="MATCH"
str2="match"
echo "The 1st string:$str1"
echo "The 2nd string:$str2"

shopt -s nocasematch
echo "The result after ignoring the case:"
case "$str1" in
    $str2 ) echo "match";;
    *) echo "no match";;
esac

# Probably wise to execute shopt -u nocasematch after the comparison is done 
# in order to revert back to bash's default.

shopt -u nocasematch
echo "The result of case sensitive:"
case "$str1" in
    $str2 ) echo "match";;
    *) echo "no match";;
esac

echo -e "\n\nMethod 2: Using BASH parameter expansion (as long as you have Bash 4)"
# In Bash, you can use parameter expansion to modify a string to all lower-/upper-case:
str1=TesT
str2=tEst

echo "Covert $str1 and $str2 to lower-case: ${str1,,} ${str2,,}"
if [ "${str1,,}" = "${str2,,}" ]; then
    echo "match"
fi

echo "Covert $str1 and $str2 to upper-case: ${str1^^} ${str2^^}"
if [ "${str1^^}" = "${str2^^}" ]; then
    echo "match"
fi

echo -e "\n\nMethod 3: Using AWK"
# otherwise, you should tell us what shell you are using. Alternative, using awk.
echo "The 1st string:$str1"
echo "The 2nd string:$str2"
awk -vs1="$str1" -vs2="$str2" 'BEGIN {
    if ( tolower(s1) == tolower(s2) ){
        print "match"
    }
}'

# Also you can give the result to a variable
comparison_result=$(awk -vs1="$str1" -vs2="$str2" 'BEGIN {
    if ( tolower(s1) == tolower(s2) ){
        print "match"
    }
}')

echo "The comparison result:$comparison_result"
