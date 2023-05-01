#!/bin/bash
ETC_HOSTS=/etc/hosts

function remove-host() {
    ip=$1
    host=$2

    host_info=$( printf "%s\t%s\n" "$ip" "$host" )
    if [ -n "$(grep -i "$host_info" $ETC_HOSTS)" ]
    then
        info "Host information $host_info was found in the file $ETC_HOSTS, removing now.";
        sudo sed -i".bak" "/$host_info/d" $ETC_HOSTS
    else
        echo "$host_info was not found in the file $ETC_HOSTS";
    fi
}

function add-host() {
    ip=$1
    host=$2
    host_info=$( printf "%s\t%s\n" "$ip" "$host" )
  
    if [ -n "$(grep -i "$host_info" $ETC_HOSTS)" ]
        then
            echo "Host information $host_info already exists : $(grep $HOSTNAME $ETC_HOSTS)"
        else
            echo "Adding $host_info to the file $ETC_HOSTS";
            sudo -- sh -c -e "echo '$host_info' >> /etc/hosts";

            if [ -n "$(grep -i $host $ETC_HOSTS)" ]
                then
                    echo "Host information $host_info was added succesfully";
                else
                    echo "Failed to add host information - $host_info !";
            fi
    fi
}