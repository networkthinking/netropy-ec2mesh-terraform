#!/bin/bash
if [ ! -f "env" ]; then
	    echo 'env does not exist. Run "terraform apply" first.'
	    exit 1
    else
	    source $(dirname "$0")/env
fi

URL=http://$NETROPY_IP/login
echo "login to $URL"
curl -c /tmp/auth.cookie -X POST -d username=admin -d password=$PASSWORD $URL
curl -b /tmp/auth.cookie -X PATCH "http://$NETROPY_IP/api/apposite-wan-emulator:engine/1/forwarding/route" -H "accept: application/json"  -H "Content-Type: application/json" --data-binary @- << EOF
[
  {
    "address": "0.0.0.0",
    "netmask": "0.0.0.0",
    "gateway": "$GATEWAY"
  }
]
EOF

if [[ $? -eq 0 ]];then
  echo "The application is ready to use"
else
  echo "Adding route failed"
fi