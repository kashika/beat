# This document is created to highlight the steps involved to do the Beat ETL assignment

# Requirements & Tools
- Pycharm (Python version 3.7)

Python Libraries-
requests
xml.etree.ElementTree
pandas
logging
traceback
argparse
datetime 


# Provided input -

Web link for API to fetch currency exchange data in json & xml format
http://api.nbp.pl/api/exchangerates/tables/A/

For this project, I have used xml to parse the data from the external API


# Command to run the script:
1. python3 currency_exchange.py

### When run using the above command-
The script will by default run for the current date and save the desired output 
in a csv file. The exchange rate in this case will be default which is "0.22"

2. python3 currency_exchange.py --startDate 2021-08-23 --endDate 2021-08-25 --exchangeRate 0.23

### When run using the above command-
The script will bypass the default values and run for the provided input range. This can be helpful for automation or 
to run the script for adhoc dates and currency exchange rates. It can save multiple files in csv format as per requirement.

# Final CSV output file format-

      date      	            | DATE	    | Date of exchange rate record 
      currenct code	            | STRING	| Three letter currency code
      euro_rate	                | DOUBLE	| Exchange rate against 1 EURO upto 4 decimal digits
      inverse   	            | DOUBLE	| Inverse of Euro rate
   
# Next Steps -
We can automate this process to run as a batch job and create a partitioned table 