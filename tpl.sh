#USAGE ./tpl.sh 3

DAY=$1
FILE=day$DAY.go     

if [ -f $FILE ]; then
   echo "File $FILE exists."
   exit 1
fi
sed "s/NN/${DAY}/g" template > $FILE