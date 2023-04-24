#!/usr/bin/env bash

url=https://www.4byte.directory/api/v1/signatures/?format=json
tmpfile=./tmp.json
dataPath=./4bytes.txt
# ua="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"

while :
do
	# break condition
	if [ $url = "null" ]
	then
    	echo "task completed."
    	rm ./tmp.json
    	break
	fi

    echo "next url : "$url
	# save tmp.json
    curl $url > $tmpfile

	{
		 nextUrl=$( cat $tmpfile | jq  -r 'if has("next") then .next else error("not found") end' ) 
	} || {
		echo "parse failed"
		sleep 1s
		continue; 
	}

	if [[ ! -s $tmpfile ]]
	then
		echo "tmp file is empty"
		continue
	fi

	url=$nextUrl
	cat tmp.json | jq -r '.results[] | [.id, .hex_signature, .text_signature] | @tsv' >> $dataPath

done

tar -czf 4bytes.tar.gz $dataPath 

rm $dataPath

