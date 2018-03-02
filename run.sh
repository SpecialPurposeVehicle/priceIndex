#!/bin/bash
# GRAB HOUSE PRICE DATA FOR STREETS
DIR="$( cd "$( dirname "$0" )" && pwd )"
cd $DIR

# Generate data for Cressingham Gardens
TOWN=London
DISTRICT=lambeth # must be lower case
ESTATE=Cressingham
STREETS="HARDEL+WALK,PAPWORTH+WAY,BODLEY+MANOR+WAY,CHANDLERS+WAY"
STREETS="$STREETS,CROSBY+WALK,CROSBY+WAY,HAMBRIDGE+WAY,LONGFORD+WALK" 
STREETS="$STREETS,ROPERS+WALK,SCARLETTE+MANOR+WAY,UPGROVE+MANOR+WAY"
OUTPUTFILE=public/data/$DISTRICT-$ESTATE.hpi.csv
./prices.sh $TOWN $DISTRICT $STREETS $OUTPUTFILE 

# Add some custom data files
echo Append public/data/2015valuations.csv 
echo Append public/data/newbuilds.csv
cat public/data/2015valuations.csv >> $OUTPUTFILE
cat public/data/newbuilds.csv >> $OUTPUTFILE

# Search properties database to add bedroom numbers to CSV
# The input /csv file must have the following file format
#   price_paid,deed_date,postcode,paon,street,town,district,dataset
#   "370000","2017-06-30","SW2 2QE","116","HARDEL WALK","LONDON","LAMBETH",dataset
DATABASE=lambeth.db
INPUTCSV=$OUTPUTFILE
OUTPUTCSV=public/data/data.csv
./findbeds.py $DATABASE $INPUTCSV $OUTPUTCSV

