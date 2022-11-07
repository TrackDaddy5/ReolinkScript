#!/bin/bash

#one stop shopping for you variables
ipAddress="YOUR IP ADDRESS"
userName="YOUR NVR USERNAME"
pwd="YOUR NVR PASSWORD"

#video channelNumber to record
channelNumber=0

#Time the motion sensor fired
now=$(date)

#image/video file names
imageFilename=$(date -d "$now" +"%m%d-%H%M-%S")

#video capture window of 30 seconds
start=$(date --date "$now - 30 seconds")
end=$(date --date "$now - 0 seconds")

startYear=`date --date="$start" '+%Y'`
startMon=`date --date="$start" '+%m'`
startDay=`date --date="$start" '+%d'`
startHour=`date --date="$start" '+%H'`
startMin=`date --date="$start" '+%M'`
startSec=`date --date="$start" '+%S'`

endYear=`date --date="$end" '+%Y'`
endMon=`date --date="$end" '+%m'`
endDay=`date --date="$end" '+%d'`
endHour=`date --date="$end" '+%H'`
endMin=`date --date="$end" '+%M'`
endSec=`date --date="$end" '+%S'`

Token=$(curl -L --insecure -X  POST "https://$ipAddress/api.cgi?cmd=Login" -H 'Content-Type: application/json' --data-raw '[{ "cmd": "Login", "param": { "User": { "Version": "0", "userName": "'${userName}'", "password": "'${pwd}'" } } } ]'  | jq -r '.[].value.Token.name' )

Filename=$(curl -L --insecure -X POST "https://$ipAddress/api.cgi?cmd=NvrDownload&token=$Token" -H 'Content-Type: application/json' --data-raw '[{ "cmd": "NvrDownload", "action": 1, "param": { "NvrDownload": { "channel": '${channelNumber}', "streamType": "sub", "StartTime": { "year": '${startYear}', "mon": '${startMon}', "day": '${startDay}', "hour": '${startHour}', "min": '${startMin}',"sec": '${startSec}'},"EndTime": { "year": '${endYear}', "mon": '${endMon}', "day": '${endDay}', "hour": '${endHour}', "min": '${endMin}', "sec": '${endSec}'}}}}]'  | jq -r '.[].value.fileList[].fileName' )

echo " "
echo "------------------ Debug Log -------------------------"
echo "start: $start --- end: $end"
echo "ImageFile: $imageFilename"
echo "$startYear $startMon $startDay $startHour $startMin $startSec"
echo "$endYear $endMon $endDay $endHour $endMin $endSec"
echo "Token: $Token"
echo "Filename: $Filename"
echo "------------------------------------------------------"
echo " "

Result=$(curl -L --insecure -X GET "https://$ipAddress/api.cgi?cmd=Download&source=$Filename&output=$Filename&token=$Token" -o ./media/$imageFilename-$channelNumber.mp4)
