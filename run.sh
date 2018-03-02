DIR="$( cd "$( dirname "$0" )" && pwd )"
cd $DIR
DATADIR=$(cat config.txt | grep dataDir= | cut -d"=" -f2)
DISTRICT=$(cat config.txt | grep district= | cut -d"=" -f2) # needs to be lower case
ESTATE=$(cat config.txt | grep estate= | cut -d"=" -f2)
ESTATECSVFILE=$DATADIR/$DISTRICT-$ESTATE.hpi.csv
./prices.sh
cat public/data/2015valuations.csv >> $ESTATECSVFILE
cat public/data/newbuilds.csv >> $ESTATECSVFILE
./prices.py
