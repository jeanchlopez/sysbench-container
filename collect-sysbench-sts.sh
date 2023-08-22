#!/bin/bash
k8cmd="${K8CMD:=oc}"
set +x
podnum=$(${k8cmd} get po -n sysbench-sts -o name | wc -l)
blocksize=""
echo "Found ${podnum} to monitor"
while true
do
   numterm=0
   for pod in $(${k8cmd} get po -n sysbench-sts -o name)
   do
      echo "Checking ${pod}"
      podterminated=$(${k8cmd} logs -n sysbench-sts ${pod} | grep 'Changing working directory to /' | grep -v 'tmp/data')
      if [ "x${podterminated}" == "x" ]     # This pod has not terminated
      then
         sleep 15
         break
      else
         numterm=$(( numterm + 1 ))
      fi
   done
   if [ ${numterm} == ${podnum} ]
   then
      echo "All pods have completed and are in sleeping mode"
      blocksize=$(${k8cmd} logs -n sysbench-sts ${pod} | grep "Block size" | awk '{print $3}')
      break
   fi
done
set +x
twiops=0
triops=0
trwiops=0
twbw=0
trbw=0
trwbw=0
tminlat=0
tavglat=0
tmaxlat=0
tpeaklat=0
for pod in $(${k8cmd} get po -n sysbench-sts -o name)
do
   iops=$(${k8cmd} logs -n sysbench-sts ${pod} | grep -A3 'File operations:')
   bw=$(${k8cmd} logs -n sysbench-sts ${pod} | grep -A2 'Throughput:')
   lat=$(${k8cmd} logs -n sysbench-sts ${pod} | grep -A4 'Latency (')
   riops=$(echo ${iops} | awk '{print $4}' | sed 's/^[[:blank:]]*//')
   wiops=$(echo ${iops} | awk '{print $6}' | sed 's/^[[:blank:]]*//')
   twiops=$(bc <<< "scale=2; $twiops + $wiops")
   triops=$(bc <<< "scale=2; $triops + $riops")
   rwiops=$(bc <<< "scale=2; $riops + $wiops")
   trwiops=$(bc <<< "scale=2; $trwiops + $rwiops")
   rbw=$(echo ${bw} | awk '{print $4}' | sed 's/^[[:blank:]]*//')
   wbw=$(echo ${bw} | awk '{print $7}' | sed 's/^[[:blank:]]*//')
   twbw=$(bc <<< "scale=2; $twbw + $wbw")
   trbw=$(bc <<< "scale=2; $trbw + $rbw")
   rwbw=$(bc <<< "scale=2; $rbw + $wbw")
   trwbw=$(bc <<< "scale=2; $trwbw + $rwbw")
   minlat=$(echo ${lat} | awk '{print $4}' | sed 's/^[[:blank:]]*//')
   avglat=$(echo ${lat} | awk '{print $6}' | sed 's/^[[:blank:]]*//')
   maxlat=$(echo ${lat} | awk '{print $8}' | sed 's/^[[:blank:]]*//')
   peaklat=$(echo ${lat} | awk '{print $11}' | sed 's/^[[:blank:]]*//')
   echo "${pod} IOPS (${blocksize})"
   echo "=========="
   echo "Read     : ${riops}"
   echo "Write    : ${wiops}"
   echo "R+W      : ${rwiops}"
   echo "Total Bandwidth MBps (${blocksize})"
   echo "Read     : ${rbw}"
   echo "Write    : ${wbw}"
   echo "R+W      : ${rwbw}"
   echo "Latency statistics (${blocksize})"
   echo "Min      : ${minlat}"
   echo "Max      : ${maxlat}"
   echo "Average  : ${avglat}"
   echo "95th     : ${peaklat}"
done
echo "Total IOPS (${blocksize})"
echo "=========="
echo "Read     : ${triops}"
echo "Write    : ${twiops}"
echo "R+W      : ${trwiops}"
echo "Total Bandwidth MBps (${blocksize})"
echo "Read     : ${trbw}"
echo "Write    : ${twbw}"
echo "R+W      : ${trwbw}"

