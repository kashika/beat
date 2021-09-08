# import libraries
import requests
import xml.etree.ElementTree as et
import pandas as pd
import logging as logger
import traceback
import argparse
from datetime import datetime, timedelta

"""
This  script is used to fetch the currency exchange rates data from an external API and store as date partitioned files
"""


try:
    # get dynamic variables for startDate, endDate and exchangeRate
    # Default value - startDate = endDate = current_date, exchangeRate = 0.22
    # these values can be passed dynamically if the requirement is to run the script for multiple days at a time
    # or to run this script for any particular day other than the current day

    parser = argparse.ArgumentParser(description='Currency Exchange Rates')
    parser.add_argument("--startDate", default=datetime.now().date())
    parser.add_argument("--endDate",  default=datetime.now().date())
    parser.add_argument("--exchangeRate", default=0.22)

    # parse dynamic arguments/take default
    args = parser.parse_args()
    startDate = args.startDate
    if type(startDate) == str:
        # This block is entered when startDate is fetched dynamically
        startDate = datetime.strptime(startDate, '%Y-%m-%d').date()

    endDate = args.endDate
    if type(endDate) == str:
        # This block is entered when endDate is fetched dynamically
        endDate = datetime.strptime(endDate, '%Y-%m-%d').date()
        if endDate<startDate:
            startDate = endDate
            print("Start date was greater than end date so it is replaced with end date")

    exchangeRate = args.exchangeRate
    if type(exchangeRate) == str:
        # This block is entered when exchangeRate is fetched dynamically
        exchangeRate = float(exchangeRate)

    logger.info("Get exchange rates from start_date: ", startDate, " to end_date: ", endDate)
    logger.info("Exchange Rate to convert PLN to EUR is: ", exchangeRate)

except Exception as ex:
    logger.error('Unexpected error: ' + traceback.format_exc())
    logger.error(ex.message)


# This function calls the api and parses the xml file to fetch the required data
def api_call(api_link):
    # get the exchange rates from the api
    xml_data = requests.get(api_link).content

    # get the root of the xml file
    root = et.XML(xml_data)

    # create an empty array which will store currency code and exchange value
    record = []

    # iterate over the xml file which is 4 levels deep to get the currency values
    for child1 in root:
        for child2 in child1:
            if child2.tag == 'EffectiveDate':
                # get the exchange rate date and replace  "-" by "" to save file in correct format
                exchange_rate_date = child2.text.replace("-", "")
            if child2.tag == 'Rates':
                for child3 in child2:
                    # Save all currency details in the array
                    curr = []
                    for child4 in child3:
                        if child4.tag == 'Code':
                            curr.append(child4.text)
                        elif child4.tag == 'Mid':
                            curr.append(child4.text)
                    # Append currency details to final record
                    record.append(curr)


    df = pd.DataFrame(record, columns = ["currency_code","Mid"])
    # create a date column with exchange_rate_date
    df['date'] = datetime.strptime(exchange_rate_date, '%Y%m%d').date()

    # create euro_rate by changing exchange rate to eur
    df["euro_rate"] = round(df['Mid'].astype(float).multiply(exchangeRate), 4)

    # cretae inverse of exchange rate
    df["inverse"] = round(1/df["euro_rate"],4)
    df = df[["date", "currency_code", "euro_rate", "inverse"]]
    logger.info(df)

    # save the output to csv
    df.to_csv("nbp_exchange_rates_{exchange_rate_date}.csv".format(exchange_rate_date=exchange_rate_date), index=False)



# This is the main block from where code execution will start
if __name__ == '__main__':
    while str(startDate) <= str(endDate):
        # api link to fetch exchange rates
        api_link = 'http://api.nbp.pl/api/exchangerates/tables/A/{date}?format=xml'.format(date=str(startDate))
        # call function with the api link
        api_call(api_link)
        startDate += timedelta(days=1)
