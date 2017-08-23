# Bitstamp-MoneyMoney

Fetches balances from Bitstamp API and returns them as securities

## Setup

* Download Bitstamp extension bitstamp.lua
* In MoneyMoney app open “Help” Menu and hit “Show database in finder” (https://moneymoney-app.com/extensions/#installation)
* Copy bitstamp.lua in extensions folder
* In MoneyMoney app open “Preferences” > “Extensions” and make sure “bitstamp” show up (to use unsigned extension uncheck “verify digital signatures of extensions” at the bottom)
* Login to bitstamp.net
* To get an API key, go to "Account" > "Security" > "API Access"
* Check permission “Account Balance” (other fields can stay blank) and hit “Generate key”
* On the next screen hit “Active key” and confirm link in bitstamp email
* Finally in MoneyMoney add new bitstamp account and use your bitstamp customer id, API key and API secret

### MoneyMoney

Add a new account (type Bitstamp Account”)

## Known Issues and Limitations

* Always assumes EUR as base currency
