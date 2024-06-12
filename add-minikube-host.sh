#!/bin/bash

if ! command -v minikube &> /dev/null
    then
		echo "minikube is not installed. Please install minikube first."
		exit 1
fi
if [ -z "$1" ]
then
	echo "Please provide a host name."
	exit 1
fi
if [ "$1" == "--help" ]
then
	echo "Usage: ./add-minikube-host.sh [HOSTNAME]"
	exit 1
fi
# insert/update hosts entry
ip_address="$(minikube ip 2>&1)"
host_name="$1"
# find existing instances in the host file and save the line numbers
matches_in_hosts="$(grep -n "\s$host_name$" /etc/hosts | cut -f1 -d:)"
host_entry="${ip_address} ${host_name}"

echo "Please enter your password if requested."

if [ ! -z "$matches_in_hosts" ]
then
    echo "Updating existing hosts entry."
    # iterate over the line numbers on which matches were found
    while read -r line_number; do
        # replace the text of each line with the desired host entry
        sudo sed -i "${line_number}s/.*/${host_entry} /" /etc/hosts
    done <<< "$matches_in_hosts"
else
    echo "Adding new hosts entry."
    echo "$host_entry" | sudo tee -a /etc/hosts > /dev/null
fi
