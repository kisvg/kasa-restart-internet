#!/bin/bash

echo 'Adding command to turn the plug back on...'
kasa --host 192.168.42.3 command --module schedule edit_rule "{\"enable\": 1,\"wday\": [1, 1, 1, 1, 1, 1, 1],\"stime_opt\": 0,\"smin\":$(((10#$(date +%H) * 60 + 10#$(date +%M))+1)) ,\"soffset\": 0,\"etime_opt\": -1,\"emin\": 0,\"eoffset\": 0,\"eact\": -1, \"repeat\": 1, \"year\": 2000, \"month\": 1, \"day\": 1, \"name\":\"yay\", \"id\": \"00963AAC3513BAC237960D423514CDF5\", \"sact\": 1}" > /dev/null
echo 'Turning off the smart plug...'
kasa --host 192.168.42.3 off > /dev/null
echo 'Done! The internet should be back up in about two minutes.'