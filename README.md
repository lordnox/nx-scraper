
Simple cheerio based webscraper. Will except an url and sum of selectors. It will use cheerio to request the selected elements and build a hash of the data found. If a hash was given it will only return if it changed.

Returns the found data as javascript strings. The data should then be parsed again to ensure the correct types are handled.