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
    Returns: A dictionary with member ID as the key and the member name as the value.
    """

    members = {} # Initialize empty members dictionary
    with open(MEMBERINFO_FILE, 'r') as file:
        reader = csv.DictReader(file) # First line in file gets treated as keys which are the columns and everything following as values for the keys
        for row in reader: 
            member_id = row['id'].strip() # Retrieve the 'id' value for that specific row
            member_name = row['name'].strip() # Retrieve the 'name' value for that specific row
            members[member_id] = member_name # Populate dictionary with key as member id and value as member name
    return members

def read_member_paid_info():
    """
    This function reads the information from the memberPaidInfo.csv file into a dictionary for quick lookups.
    Returns: A dictionary with transaction data.
    """

    transactions = {} # Initialize empty transactions dictionary
    with open(MEMBERPAIDINFO_FILE, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            t_id = row['id'].strip()
            t_name = row['name'].strip()
            # Try and except block used to handle price data that may not be numerical
            try:
                t_price = float(row['price']) # Convert price to floating number
            except ValueError: # If the price value cannot be converted to floating number
                continue # Skip that data and move to next
            transactions.append({ # Append to transactions dictionary
                'id': t_id,
                'name': t_name,
                'price': t_price
            })
    return transactions
