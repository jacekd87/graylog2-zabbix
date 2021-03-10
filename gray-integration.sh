#!/bin/bash
USER=s_monitoring
PASSWORD=''

function Validate_IP()
{
        local  IP=${1}
        local  stat=1

        if [[ ${IP} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                OIFS=${IFS}
                IFS='.'
                IP=(${IP})
                IFS=${OIFS}
                [[ ${IP[0]} -le 255 && ${IP[1]} -le 255 \
                        && ${IP[2]} -le 255 && ${IP[3]} -le 255 ]]
                stat=$?
        fi
        return ${stat}
}

Validate_IP ${1}
if [ $? -ne 0 ]; then
        echo Not valid IP
        exit
fi
HOSTIP=${1}

# Validate positive number
if [[ ${2} =~ ^[0-9]+$ ]]; then
        DATETIME=$((`date +%s`-${2}))
        if [ ${DATETIME} -lt 0 ]; then
                DATETIME=$((`date +%s`-900))
        fi
else
        DATETIME=$((`date +%s`-900))
fi

if [ -z ${3} ]; then
        echo "No search string present"
        exit 1
fi

QUERY="source%3A${4}%20AND%20EventType%3AERROR"

# Graylog time definition as Keyword: "10 days ago"
KEYWORD="last%205%20minutes"
FIELDS="EventType"

if [ "x${3}" = "xstatus" ]; then
        curl -k -s -H 'Accept: text/csv' -u ${USER}:${PASSWORD} -X GET "https://esk-graylog2.eskom.local:9000/api/search/universal/keyword?query=${QUERY}&keyword=${KEYWORD}&fields=${FIELDS}&pretty=true" | grep -v "\"timestamp\",\"EventType\"" | wc -l
#curl -k -s -H "Accept: text/csv" -u ${USER}:${PASSWORD} -X GET "https://192.168.8.21:9000/api/search/universal/keyword?query=${QUERY}&keyword=${KEYWORD}&fields=${FIELDS}&pretty=true"  | \
#egrep -e  "\"fields\" : \[ \"EventType\", \"timestamp\" \]," | wc -l

        exit 0
fi

QUERY1="source%3AESK-VEEAMBR1%20AND%20EventType%3AERROR%20AND%20NOT%20(full_message%3A%22Urz%C4%85dzenie%22%20AND%20full_message%3A%22nie%20jest%20jeszcze%20przygotowane%20do%20dost%C4%99pu.%22)"

if [ "x${3}" = "xveeambr" ]; then
        curl -k -s -H 'Accept: text/csv' -u ${USER}:${PASSWORD} -X GET "https://esk-graylog2.eskom.local:9000/api/search/universal/keyword?query=${QUERY1}&keyword=${KEYWORD}&fields=${FIELDS}&pretty=true" | grep -v "\"timestamp\",\"EventType\"" | wc -l

        exit 0
fi


echo "Invalid script mode"
exit 1
