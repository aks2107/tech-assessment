import csv
import os

DATA_DIR = 'data'
OUTPUT_DIR = 'output'
MEMBERINFO_FILE = os.path.join(DATA_DIR, 'memberInfo.csv') # This allows the path to working on any OS such as Windows or Mac
MEMBERPAIDINFO_FILE = os.path.join(DATA_DIR, 'memberPaidInfo.csv')
OUTPUT_FILE = os.path.join(OUTPUT_DIR, 'cleanData.csv')

def check_directories():
    """
    This function checks to make sure the required directories are present. 
    If an output directory is missing it gets created.
    If the input files and directory is not present then the program terminates alerting the user that something is missing.
    """

    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
    if not os.path.exists(DATA_DIR):
        print("The data directory is missing and the script will terminate.")
        exit(1)
    if not os.path.exists(MEMBERINFO_FILE):
        print("memberinfo.csv is missing and the script will terminate.")
        exit(1)
    if not os.path.exists(MEMBERPAIDINFO_FILE):
         print("memberPaidInfo.csv is missing and the script will terminate.")
         exit(1)

def read_member_info():
    """
    This function reads the information from the memberInfo.csv file into a dictionary for quick lookups.
    Returns: A dictionary format with the key-value pairs.
    """

    members = {} # Initialize empty dictionary
    with open(MEMBERINFO_FILE, 'r') as file:
        reader = csv.DictReader(file) # First line in file gets treated as keys which are the columns and everything following as values for the keys
        for row in reader: 
            member_id = row['id'].strip # Retrieve the 'id' value for that specific row
            member_name = row['name'].strip() # Retrieve the 'name' value for that specific row
            members[member_id] = member_name # Populate dictionary with key as member id and value as member name
    return members



