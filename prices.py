#!/bin/python3
import sqlite3
import csv
import subprocess


class housePrices:

    # Create a new database connection _
    def __init__(self, dbfile, mycsvfile):
        self.msg = '\n=======__init--() ==='
        self.uniqueproperties = {}
        try:
            self.dbfile = dbfile
            self.mycsvfile = mycsvfile
            self.db = sqlite3.connect(self.dbfile)
            self.cursor = self.db.cursor()
            self.msg += '\nStarted DB'
        except Exception as e:
            self.msg += '\nERROR: '+str(e)


    def opencsv(self):
        # First add the 2015 valuations data
        with open(self.mycsvfile) as csvfile:
            self.readCSV = csv.reader(csvfile, delimiter=',')
            i=0
            for row in self.readCSV:
                # 145000 2002-02-11 SW2 2QY T 18 UPGROVE MANOR WAY LONDON
                #print(row[0], row[1], row[2], row[3], row[4])
                # Create  query for each property
                key = '{}{}'.format(row[3], row[4]) # num, street
                qry="SELECT DISTINCT address1, street, beds FROM properties  WHERE street='{}' AND address1='{}'".format( row[4], row[3])
                if i>0:
                    self.uniqueproperties[key] = {'qry':qry, 'row':row}
                print(key)
                i=i+1
            self.msg += 'HouseQueries: {}\n'.format(len(self.uniqueproperties))

    def findbeds(self):
        for home in self.uniqueproperties:
            qry = self.uniqueproperties[home]['qry']
            row = self.uniqueproperties[home]['row']
            self.cursor.execute(qry)
            result = self.cursor.fetchone()
            if '{}'.format(result)=='None':
                self.msg+='NOT FOUND: "{} {}"\n'.format(row[3], row[4])
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
        f = open('public/data/data.csv','w')
        f.write(text)


    def query(self):
        qry = """
        SELECT DISTINCT p.estate_id, p.UPRN
        FROM blocks b
        LEFT JOIN properties p
        ON b.block_id=p.block_id;
        """
        self.cursor.execute(qry)
        rows = self.cursor.fetchall()
        for row in rows:
            block_id=row[0]
            estate_id=row[2]
            short_address=row[1]
            uprn=row[3]
            qry = '''UPDATE properties SET short_address=? WHERE UPRN=?'''
            #self.db.execute(qry, (short_address, uprn) )
            #print('{} {} {} {}'.format(uprn, block_id, estate_id, short_address))
            print(qry)
        #self.db.commit()

if __name__ == "__main__":
    dbfile="/home/tom/Documents/04.Projects/PHDHousingDatabase/09LambethCressingham/CG-Data/DBweb/lambeth.db"
    mycsvfile="public/data/lambeth-Cressingham.hpi.csv"
    reporter = housePrices(dbfile, mycsvfile)
    reporter.opencsv()
    reporter.findbeds()
    print(reporter.msg)
