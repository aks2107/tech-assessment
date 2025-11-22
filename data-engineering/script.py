import csv
import os

DATA_DIR = 'data'
OUTPUT_DIR = 'output'
MEMBERINFO_FILE = os.path.join(DATA_DIR, 'memberInfo.csv') # This allows the path to working on any OS such as Windows or Mac
MEMBERPAIDINFO_FILE = os.path.join(DATA_DIR, 'memberPaidInfo.csv')
OUTPUT_FILE = os.path.join(OUTPUT_DIR, 'cleanData.csv')

