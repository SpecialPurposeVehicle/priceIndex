# GRAB A LIST OF HOUSE PRICES FOR A LIST OF STREETS

TOWN=$1                                # London                  #
DISTRICT=$2                            # lambeth                 # lowercase
STREETS=$(echo $3 | sed 's/,/ /g')     # HARDEL+WALK BODLEY+WAY  # uppercase
OUTPUTFILE=$4                          # output.csv
HEADER="&header=true"

# Grab the latest house price data & stripout colums of uneeded data
rm $OUTPUTFILE
echo Run \"prices.sh\". Getting house prices for streets in $DISTRICT:
for STREET in $STREETS
do
    URL="http://landregistry.data.gov.uk/app/ppd/ppd_data.csv?district=$DISTRICT&limit=all&street=$STREET&town=$TOWN$HEADER"
    wget $URL -O /tmp/data.csv &> /dev/null
    cut -d, -f2,3,4,9,10,12,13 /tmp/data.csv |\
    awk -F"," 'BEGIN { OFS = "," } {$8="dataset"; print}' \
    >> $OUTPUTFILE
    echo "     Grabbed: $STREET"
    HEADER=""
done
H=$(head -n1 $OUTPUTFILE)
echo -e "     Generated \"$OUTPUTFILE\" file with colums:\n     $H"

# Grab the averages for the region & stripout colums of uneeded data
FROM='1993-01-01'
TO='2018-01-01'
echo "     Grabbed monthly average house prices for $DISTRICT from $FROM to $TO"
URL="http://landregistry.data.gov.uk/app/ukhpi/download/new.csv?from=$FROM&to=$TO&location=http%3A%2F%2Flandregistry.data.gov.uk%2Fid%2Fregion%2F$DISTRICT"
wget $URL -O /tmp/data.csv &> /dev/null
cut -d, -f4,7 /tmp/data.csv | \
awk -F"," 'BEGIN { OFS = "," } {$1=$1"-01";$8="dataset";$7="'$DISTRICT'";$6="'$TOWN'"; print}' |\
awk -F, '{print $2,$1,$3,$4,$5,$6,$7,$8}' OFS=, \
> /tmp/data2.csv
H=$(head -n1 /tmp/data2.csv)
tail -n +2 /tmp/data2.csv > /tmp/data.csv
cat /tmp/data.csv >> $OUTPUTFILE

# Clean up
rm /tmp/data.csv
rm /tmp/data2.csv
