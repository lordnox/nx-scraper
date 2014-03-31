
request = require 'request'
crypto  = require 'crypto'

{helpers}       = require 'coffee-script'
{EventEmitter}  = require 'events'


defaults =
  hash        : false
  method      : 'GET'
  hashFn      : 'sha512'
  hashDigest  : 'hex'

class Scraper extends EventEmitter
  constructor: (url, options) ->
    return new Scraper(url, options) if not (@ instanceof Scraper)
    @url        = url
    @options    = helpers.merge defaults, options or {}
    @selectors  = []

  match: (key, selector, type = 'string') ->
    @selectors.push
      key     : key
      selector: selector
      type    : type

  scrape: (fn) ->
    fn    = fn || (err, data, hash) =>
      return @emit 'error', err if err
      @emit 'scraped',
        data: data
        hash: hash

    request @url, (err, res, body) =>
      return fn err if err
      return fn null, body if not @options.hash
      hashFn  = crypto.createHash(@options.hashFn).update body
      hash    = hashFn.digest @options.hashDigest
      fn null, body, hash if hash isnt @options.hash
      @options.hash = hash

module.exports = Scraper




