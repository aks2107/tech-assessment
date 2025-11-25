# Data Engineering Assignment D0 - Design Choices

## 1. Project Architecture
### Dynamic File Paths
Python's `os` module is used to generate paths dynamically. This helps with avoiding the bad practices of hardcoding absolute paths and guessing that the script is going to be run from a specific root.

### Structure of Files and Directories
The project structure separates files and directories into three things:
- **Input** (`data/`)
- **Script** (`script.py`)
- **Output** (`output/`)

Reasoning: This keeps the repository organized. The script automatically generates the `output/` directory if it is missing.

## 2. Data Cleaning Strategy
The main challenge of this assignment is merging two datasets with potential conflicts and missing data. To tackle this challenge I did the following:

### A. ID Validation
- Transactions are only processed if the `memberId` exists in the `memberInfo.csv` otherwise they are discarded.
- Reasoning: Transactions for non-existent members should not be reviewed and mixed with member data.

### B. Conflict Resolution
- If a member's name exists in the transaction list but is different from the name in memberInfo, the record is discarded.
- Reasoning: Conflicting data needs to be resolved and removing names that are invalid help with data integrity and reliable data.

### C. Missing Data Handling
- The script uses the name from `memberPaidInfo` for `cleanData.csv`.  
If the name is missing from `memberPaidInfo`, it takes the ID from that file and finds the name associated with that same ID in `memberInfo`.
- Edge case: If a name is missing in both files, the record is just skipped.
- Reasoning: This helps keep only reliable data and makes sure that a transaction is only discarded when there is missing information that cannot be recovered from both of the files.

## 3. Technical Implementation

### Standard Python Library
I chose to use Python's built-in `csv` and `os` libraries because the 
script can run on any standard Python installation without needing `pip install`.

### Data Structures & Complexity
I loaded `memberInfo` into a Python Dictionary rather than a list.

Performance: This allows for O(1) (constant time) lookup when checking if a transaction ID is valid. Using a list would have made the time complexity slower.

## 4. Error Handling
The script includes logic for errors during the beginning. It checks for all required files and directories immediately before doing any data reading and cleaning.

Reasoning: It is better to alert the user immediately about missing input files and incorrect file structure than to run all the way through and then crash at a random point.