# -*- coding: utf-8 -*-
# Copyright (c) 2013 Jendrik Poloczek
# Copyright (c) 2013 Tao Sauvage
# Copyright (c) 2014 Aborilov Pavel
# Copyright (c) 2014 Sean Vig
# Copyright (c) 2014-2015 Tycho Andersen
# Copyright (c) 2021 Graeme Holliday
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import locale

from libqtile.confreader import ConfigError
from libqtile.log_utils import logger
from libqtile.widget.generic_poll_text import GenPollUrl

_DEFAULT_CURRENCY = str(locale.localeconv()["int_curr_symbol"])
_DEFAULT_SYMBOL = str(locale.localeconv()["currency_symbol"])


class CustomCryptoTicker(GenPollUrl):
    """
    A cryptocurrency ticker widget, data provided by the coinbase.com or the binance.com
    API. Defaults to displaying currency in whatever the current locale is. Examples:

        # display the average price of bitcoin in local currency
        widget.CryptoTicker()

        # display it in Euros:
        widget.CryptoTicker(currency="EUR")

        # or a different cryptocurrency!
        widget.CryptoTicker(crypto="ETH")

        # change the currency symbol:
        widget.CryptoTicker(currency="EUR", symbol="€")

        # display from Binance API
        widget.CryptoTicker(api="binance", currency="USDT")
    """

    QUERY_URL_DICT = {
        "coinbase": (
            "https://api.coinbase.com/v2/prices/{}-{}/spot",
            lambda x: float(x["data"]["amount"]),
        ),
        "binance": (
            "https://api.binance.com/api/v3/ticker/price?symbol={}{}",
            lambda x: float(x["price"]),
        ),
        "kucoin": (
            "https://api.kucoin.com/api/v1/market/orderbook/level1?symbol={}-{}",
            lambda x: float(x["data"]["price"]),
        ),
    }

    defaults = [
        (
            "currency",
            _DEFAULT_CURRENCY.strip(),
            "The baseline currency that the value of the crypto is displayed in.",
        ),
        ("symbol", _DEFAULT_SYMBOL, "The symbol for the baseline currency."),
        ("crypto", "BTC", "The cryptocurrency to display."),
        ("format", "{crypto}: {symbol}{amount:.2f}", "Display string formatting."),
        ("api", "coinbase", "API that provides the data."),
    ]

    def __init__(self, **config):
        GenPollUrl.__init__(self, **config)
        self.add_defaults(CustomCryptoTicker.defaults)

        # set up USD as the currency if no locale is set
        if self.currency == "":
            self.currency = "USD"
        # set up $ as the symbol if no locale is set
        if self.symbol == "":
            self.symbol = "$"

    def _configure(self, qtile, bar):
        try:
            GenPollUrl._configure(self, qtile, bar)
            self.query_url = self.QUERY_URL_DICT[self.api][0]
        except KeyError:
            apis = sorted(self.QUERY_URL_DICT.keys())
            logger.error(
                "%s is not a valid API. Use one of the list: %s.",
                self.api,
                apis,
            )
            raise ConfigError("Unknown provider passed as 'api' to CryptoTicker")

    @property
    def url(self):
        return self.query_url.format(self.crypto, self.currency)

    def parse(self, body):
        variables = dict()
        variables["crypto"] = self.crypto
        variables["symbol"] = self.symbol
        variables["amount"] = self.QUERY_URL_DICT[self.api][1](body)

        if self.crypto == "BTC" and self.currency in ["USD", "USDT", "USDC"]:
            variables["amount"] /= 1000

        return self.format.format(**variables)
