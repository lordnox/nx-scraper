
cheerio = require 'cheerio'
crypto  = require 'crypto'
Q       = require 'q'
async   = require 'async'

###


  'selector': name

###

Parser =
  context : (html) -> cheerio.load html
  text    : (results)   ->
    return false if not results.length
    res.data for res in results.contents()
  string  : ($, {selector}) -> Parser.text $ selector
#  array   : ($, rules)  ->
  obj     : ($, obj)  ->
    list = []
    $(obj.selector).each (i, element) ->
      res = {}
      list.push res
      context = Parser.context @.html()
      console.log context.html()
      console.log i, obj.rules
      for key, rule of obj.rules
        console.log key, rule
        res[key] = Parser.parse context, rule

    console.log list
    false

  parse   : ($, rule)  ->
    # if rule has property 'key' create a list of object of each result
    return Parser.obj $, rule if rule.hasOwnProperty "rules"
    Parser.string $, rule



parser = (html, rule) ->
  $ = Parser.context html
  Parser.parse $, rule

module.exports = parser




