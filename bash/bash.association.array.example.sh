#!/bin/bash

echo "Association arrary example 1st:"
declare -A city_array
city_array=([JD]=Beijing [ELM]=Shanghai [HW]=Shenzhen)
for key in ${!city_array[*]}
do
    echo "${key} comes from ${city_array[$key]}"
done

echo -e "\nAssociation arrary example 2nd:"
rm -f rss_hash_functions.txt
echo -e "toeplitz: on \n xor: off \n  crc32: off" >> rss_hash_functions.txt

declare -A rss_hash_array
GetRSSHashFunctions()
{
    IFS_OLD=$IFS
    IFS=':'
    while read k v
    do
        k=${k// /}   # Remove space
        v=${v// /}
        echo "key=value ---- $k = $v"
        rss_hash_array[$k]=$v
    done < rss_hash_functions.txt
    IFS=$IFS_OLD
}

GetRSSHashFunctions

echo -e "\nParse !ArrayName[@] \n"
for key in ${!rss_hash_array[@]}
do
    echo "The key is $key"
done

echo -e "\nParse ArrayName[@] \n"
for value in ${rss_hash_array[@]}
do
    echo "The value is $value"
done

echo -e "\nParse !ArrayName[*] \n"
for key in ${!rss_hash_array[*]}
do
    echo "The key is $key"
done

echo -e "\nParse ArrayName[*] \n"
for value in ${rss_hash_array[*]}
do
    echo "The value is $value"
done

echo -e "\n With ! is KEY; without ! is VALUEE"
