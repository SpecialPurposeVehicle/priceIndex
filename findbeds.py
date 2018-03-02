#!/bin/python3
import sqlite3
import csv
import sys
import os.path

class housePrices:

    # Create a new database connection _
    def __init__(self):
        print('Run "findbeds.py. Adding beds data to csv file"')
        dbfile = mycsvfile = -1 
        if len(sys.argv) == 4:
            dbfile = sys.argv[1]
            mycsvfile = sys.argv[2]
            outputfile = sys.argv[3]
        if os.path.exists(dbfile) and os.path.exists(mycsvfile):
            print('     Reading: {} | {}'.format(dbfile,mycsvfile))
        else:
            print('     To run this script and specify a database, .csv, and output file:')
            print('          $ ./prices.py lambeth.db public/data/lambeth-Cressingham.hpi.csv public/data/data.csv')
            print('     Make sure the files exist')
            exit()
        self.uniqueproperties = {}
        try:
            self.outputfile = outputfile
            self.dbfile = dbfile
            self.mycsvfile = mycsvfile
            self.db = sqlite3.connect(self.dbfile)
            self.cursor = self.db.cursor()
        except Exception as e:
            self.msg += '\nERROR: '+str(e)


    def opencsv(self):
        # First add the 2015 valuations data
        with open(self.mycsvfile) as csvfile:
            self.readCSV = csv.reader(csvfile, delimiter=',')
            i=0
            for row in self.readCSV:
                # Create  query for each property
                key = '{}{}'.format(row[3], row[4]) # num, street
                qry="SELECT DISTINCT address1, street, beds FROM properties  WHERE street='{}' AND address1='{}'".format( row[4], row[3])
                if i>0:
                    self.uniqueproperties[key] = {'qry':qry, 'row':row}
                i=i+1
            print('     Searched for "{}" properties'.format(len(self.uniqueproperties)))

    def findbeds(self):
        for home in self.uniqueproperties:
            qry = self.uniqueproperties[home]['qry']
            row = self.uniqueproperties[home]['row']
            self.cursor.execute(qry)
            result = self.cursor.fetchone()
            if '{}'.format(result)=='None':
                print('     Adddress not found: "{} {}"\n'.format(row[3], row[4]))
                if row[3]=='' and row[3]=='':
                    tag = '{} average'.format(row[6])
                else:
                    tag = 'beds not listed'
            else:
                tag = '{} bed'.format(result[2])
            self.uniqueproperties[home]['tag'] = tag
        self.addbedtocsv()

    def addbedtocsv(self):
        text = ''
        i=0
        with open(self.mycsvfile) as csvfile:
            self.readCSV = csv.reader(csvfile, delimiter=',')
            for row in self.readCSV:
                key = '{}{}'.format(row[3], row[4])
                if i==0:
                    text = '{},{}'.format(','.join(row),'tag')
                else:
                    tag = self.uniqueproperties[key]['tag']
                    text = '{}\r\n{},{}'.format(text,','.join(row),tag)
                i=i+1
        f = open(self.outputfile,'w')
        f.write(text)

if __name__ == "__main__":
    # Set the database file and csv file in the config
    reporter = housePrices()
    reporter.opencsv()
    reporter.findbeds()
