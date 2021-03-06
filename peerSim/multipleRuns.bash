#!/bin/bash -u

echo "Do only ExtractStatistics ?"
echo "type y or n"
read choice

if [ $choice = "y" ]; then
  onlyExtractAverage=true
else
  onlyExtractAverage=false
fi

declare -a names=("Nodes" "Contents" "Users" "Trials" "Storage" "Processing" "Transmission" "FailureMagnification")
declare -a parameters=("totalNodes" "totalContents" "users" "totalTrials" "maxStorageCapacity" "maxProcessingCapacity" "maxTransmissionCapacity" "failureMagnification")

echo "Changed Parameter"
echo "   0. Number of Nodes"
echo "   1. Number of Contents"
echo "   2. Number of Users"
echo "   3. Number of Trials"
echo "   4. Storage Capacity"
echo "   5. Processing Capacity"
echo "   6. Transmission Capacity"
echo "   7. Failure Magnification"
echo "Select a Number"
read answer

parameterName=${parameters[$answer]}
directoryName=${names[$answer]}

echo "Input values"
declare -a array=()
read array

# values=""
totalTry=10

for value in ${array[@]}; do
  if [ $onlyExtractAverage = false ]; then
    path="${directoryName}${value}"
    rm -rf result/${path}/
  fi

  # java ChangeParameter ${parameterName} ${value} ${directoryName}
  # values="$values$value,"

  if [ $onlyExtractAverage = false ]; then
    for ((tryCount=0; tryCount < $totalTry; tryCount++)); do
      java ChangeParameter ${tryCount} ${parameterName} ${value} ${directoryName}
      java -cp "src:peersim-1.0.5.jar:jep-2.3.0.jar:djep-1.0.0.jar" peersim.Simulator src/main/config.txt

      cd ./result/
      gnuplot plot.plot
      cd ../
    done
  fi

  java ExtractStatistics ${totalTry} ${value} ${directoryName}
  java ExtractDifference ${directoryName} ${value}
  java ChangeParameter ${parameterName} ${value} ${directoryName}

cd ./result/
gnuplot average.plot
cd ../

done