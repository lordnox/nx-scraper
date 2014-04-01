
cheerio = require 'cheerio'
crypto  = require 'crypto'
Q       = require 'q'
async   = require 'async'

log     = require('debug') 'nx-scraper::parser'

Parser =
  context : (html) -> cheerio.load(html)
  text    : ($, selector, single)   ->
    results = if typeof $ is 'function' then $ selector else $.find selector
    return false if not results.length
    return results.contents()[0]?.data or false if single
    res.data for res in results.contents()
  string  : ($, {selector, single}) -> Parser.text $, selector, single
  singleObj: ($, context, rules) ->
    found   = false
    result  = {}
    Object.keys(rules).forEach (key) ->
      res = Parser.parse context, rules[key]
      return if res is false
      result[key] = res
      found       = true
    return false if not found
    result
  obj     : ($, obj)  ->
    selection = $ obj.selector
    # single-obj
    return Parser.singleObj $, selection, obj.rules if obj.single

    # multible-obj
    result = []
    selection.each (i, element) ->
      res = Parser.singleObj $, $(@), obj.rules
      result.push res if res
    result

  parse   : ($, rule)  ->
    log $.html()
    # if rule has property 'key' create a list of object of each result
    return Parser.string $, selector: rule, single: true if typeof rule is 'string'
    return Parser.obj $, rule if rule.hasOwnProperty "rules"
    Parser.string $, rule

parser = (html, rule) ->
  $ = Parser.context html
  Parser.parse $, rule

module.exports = parser




