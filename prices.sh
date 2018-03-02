# GRAB A LIST OF HOUSE PRICES FOR A LIST OF STREETS

# Prep variables
DATADIR=$(cat config.txt | grep dataDir= | cut -d"=" -f2)
TOWN=$(cat config.txt | grep town= | cut -d"=" -f2)
DISTRICT=$(cat config.txt | grep district= | cut -d"=" -f2) # needs to be lower case
ESTATE=$(cat config.txt | grep estate= | cut -d"=" -f2)
STREETS=$(cat config.txt | grep streets= | cut -d"=" -f2)
#STREETS="HARDEL+WALK"
HEADER="&header=true"
ESTATECSVFILE=$DATADIR/$DISTRICT-$ESTATE.hpi.csv

# Grab the latest house price data & stripout colums of uneeded data
rm $ESTATECSVFILE
echo Getting HPI data for streets on \"$ESTATE\" in "$DISTRICT"
for STREET in $STREETS
do
    URL="http://landregistry.data.gov.uk/app/ppd/ppd_data.csv?district=$DISTRICT&limit=all&street=$STREET&town=$TOWN$HEADER"
    wget $URL -O /tmp/data.csv &> /dev/null
    cut -d, -f2,3,4,9,10,12,13 /tmp/data.csv |\
    awk -F"," 'BEGIN { OFS = "," } {$8="dataset"; print}' \
    >> $ESTATECSVFILE
    echo "     Grabbed: $STREET"
    HEADER=""
done
H=$(head -n1 $ESTATECSVFILE)
echo -e "Generated \"$DISTRICT-$ESTATE.hpi.csv\" file: \n    $H"

# Grab the averages for the region & stripout colums of uneeded data
FROM='1993-01-01'
TO='2018-01-01'
URL="http://landregistry.data.gov.uk/app/ukhpi/download/new.csv?from=$FROM&to=$TO&location=http%3A%2F%2Flandregistry.data.gov.uk%2Fid%2Fregion%2F$DISTRICT"
wget $URL -O /tmp/data.csv &> /dev/null
cut -d, -f4,7 /tmp/data.csv | \
awk -F"," 'BEGIN { OFS = "," } {$1=$1"-01";$8="dataset";$7="'$DISTRICT'";$6="'$TOWN'"; print}' |\
awk -F, '{print $2,$1,$3,$4,$5,$6,$7,$8}' OFS=, \
> /tmp/data2.csv
H=$(head -n1 /tmp/data2.csv)
echo -e "Generated \"$DISTRICT.hpi.csv\" file: \n     $H"
tail -n +2 /tmp/data2.csv > /tmp/data.csv
cat /tmp/data.csv >> $ESTATECSVFILE

# Clean up
#cat $ESTATECSVFILE
rm /tmp/data.csv
rm /tmp/data2.csv

# Add the 2015 data
cat public/data/2015valuations.csv >> $ESTATECSVFILE
cat public/data/newbuilds.csv >> $ESTATECSVFILE
./prices.py
