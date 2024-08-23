#!/bin/bash
#A script to check which binaries on the system have the SUID set, compare that to the GTFOBins list, and output the commands for privilege escalation
#Mostly written for practice with bash scripting and using sed

echo "Getting list of binaries with SUID"

bins=($(find / -user root -perm -4000 2>/dev/null | sed 's|^.*/||'))

echo "Getting list of vulnerable binaries from GTFObins.github.io"

gtfobins=($(curl -s https://gtfobins.github.io | grep -o 'class="bin-name"[^>]*>[^<]*</a>' | sed -e 's/^[^>]*>//' -e 's/<.*$//'))

suidbins=()

for i in ${bins[*]}
do
	for j in ${gtfobins[*]}
	do
		if [ "$i" == "$j" ]
		then
			suidbins+=("$i")
		fi
	done
done

test=()
bins2=()

for i in ${suidbins[*]}
do
	test+=($(curl -s https://gtfobins.github.io/gtfobins/$i/ | grep -o 'SUID'))
	if [ "${test[$i]}" == "SUID" ]
	then
		echo "Binary $i exploitable with SUID"
		bins2+=($i)
	fi
done

if [ ${#bins2[@]} -eq 0 ]
then
	echo "No binaries on the system appear to be exploitable"
	exit 0
fi

echo "Getting SUID privilege escalation commands from GTFObins:"
suidcode=()

for i in ${bins2[*]}
do
	suidcode+=("$i:\n")
	suidcode+=($(curl -s https://gtfobins.github.io/gtfobins/$i/ | sed -n '/<h2 id="suid" class="function-name">SUID<\/h2>/,/<\/li>/p' | sed -n '/<pre><code>/,/<\/code><\/pre>/p' | sed 's/<\/\?\(pre\|code\)>//g'))
	suidcode+=('\n---\n')

done

echo -e "${suidcode[*]}"
