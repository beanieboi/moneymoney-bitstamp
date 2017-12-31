-- Inofficial Bitstamp Extension (www.bitstamp.net) for MoneyMoneyApp
-- Fetches balances from Bitstamp API and returns them as securities
--
-- Username: Bitstamp Customer ID
-- Username2: Bitstamp API Key
-- Password: Bitstamp API Secret
--
-- Copyright (c) 2017 beanieboi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

WebBanking{
  version = 1.0,
  url = "https://www.bitstamp.net",
  description = "Fetch balances from Bitstamp API and list them as securities",
  services= { "Bitstamp Account" },
}

local apiKey
local apiSecret
local apiVersion = "v2"
local currency = "EUR" -- fixme: Don't hardcode
local currencyName = "EUR" -- fixme: Don't hardcode
local market = "Bitstamp"
local accountName = "Balances"
local accountNumber = "Main"
local balances
local customerId

local currencyNames = {
  BTC = "Bitcoin",
  BCH = "Bitcoin Cash",
  ETH = "Ether",
  LTC = "Litecoin",
  XRP = "Ripple",
  EUR = "Euro",
  USD = "US Dollar"
}

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Bitstamp Account"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  apiKey = username2
  apiSecret = password
  customerId = username

  balances = queryPrivate("balance")

  prices = {
    BTC = queryPublic("ticker/btceur"),
    BCH = queryPublic("ticker/bcheur"),
    ETH = queryPublic("ticker/etheur"),
    LTC = queryPublic("ticker/ltceur"),
    XRP = queryPublic("ticker/xrpeur"),
    USD = invertPrices(queryPublic("ticker/eurusd")),
    EUR = { vwap= 1 }
  }
end

function ListAccounts (knownAccounts)
  local account = {
    name = accountName,
    accountNumber = accountNumber,
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local name
  local currencyName
  local s = {}

  for key, value in pairs(balances) do
    if string.match(key, "_balance") then

      currencyName, stringBalance = key:match("(.*)_(.*)")
      currencyName = currencyName:upper()

      name = currencyNames[currencyName] ~= nil and currencyNames[currencyName] or currencyName

      if (prices[currencyName] ~= nil or key == currencyName) and tonumber(value) > 0 then
        s[#s+1] = {
          name = name,
          market = market,
          currency = nil,
          quantity = value,
          price = prices[currencyName] ~= nil and prices[currencyName]["vwap"] or 1
        }
      end
    end
  end

  return {securities = s}
end

function EndSession ()
end

function queryPrivate(method, request)
  if request == nil then
    request = {}
  end

  local path = string.format("/api/%s/%s/", apiVersion, method)
  local nonce = string.format("%d", math.floor(MM.time() * 1000000))
  local message = nonce .. customerId .. apiKey
  local signature = string.upper(bin2hex(MM.hmac256(apiSecret, message)))

  request["nonce"] = nonce
  request["key"] = apiKey
  request["signature"] = signature

  local postData = httpBuildQuery(request)

  connection = Connection()
  content = connection:request("POST", url .. path, postData, "application/x-www-form-urlencoded; charset=UTF-8")

  json = JSON(content)

  return json:dictionary()
end

function queryPublic(method, request)
  if request == nil then
    request = {}
  end

  local path = string.format("/api/%s/%s/", apiVersion, method)
  local postData = httpBuildQuery(request)

  connection = Connection()
  content = connection:request("POST", url .. path, postData)
  json = JSON(content)

  return json:dictionary()
end

function bin2hex(s)
 return (s:gsub(".", function (byte)
   return string.format("%02x", string.byte(byte))
 end))
end

function httpBuildQuery(params)
  local str = ''
  for key, value in pairs(params) do
    str = str .. key .. "=" .. value .. "&"
  end
  return str.sub(str, 1, -2)
end

function invertPrices(prices)
  local newPrices = {}
  for key,value in pairs(prices) do
    newPrices[key] = 1 / value
  end

  return newPrices
end
