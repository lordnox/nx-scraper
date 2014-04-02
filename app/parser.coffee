
cheerio   = require 'cheerio'
crypto    = require 'crypto'
Q         = require 'q'
async     = require 'async'
log       = require('debug') 'nx-scraper::parser'
{helpers} = require 'coffee-script'



Parser =
  context : (html) ->
    context = cheerio.load(html)
    # consolidate cheerio's api:
    context.find = (s) -> context s
    context

  textTree: (children) ->
    children.map (child) ->
      return child.data if child.type is 'text'
      Parser.textTree child.children

  text    : ($, selector, single, list)   ->
    results = $.find selector
    return false if not results.length
    return results.eq(0).text() or false if single

    result = helpers.flatten if list
      (Parser.textTree(results[index].children) for index in [0..results.length - 1])
    else
      (results.eq(index).text() or false for index in [0..results.length - 1])

    # trim non-strings
    leaf for leaf in result when typeof leaf is 'string'

  string  : ($, {selector, single, list}) ->
    text = Parser.text $, selector, single, list
    log "string(#{!!single}): " + text
    text

  singleObj: ($, {join, rules, needs}) ->
    found   = false
    result  = {}
    needs   = Object.keys rules if needs and needs is true

    Object.keys(rules).forEach (key) ->
      res = Parser.parse $, rules[key]
      return if res is false
      result[key] = res
      found       = true

    if needs
      for need in needs
        # eject
        return false if not result.hasOwnProperty need

    return false if not found

    if join
      join = Object.keys rules if join is true
      log "joining " + join.join(',')
      properties = [].concat join
      while properties.length
        property = properties.pop()
        return result[property] if result.hasOwnProperty property
        # eject
      return false

    result

  obj     : ($, obj)  ->
    log "object"
    selection = $.find obj.selector
    # single-obj
    return Parser.singleObj selection, obj if obj.single

    # multible-obj
    result = []
    selection.each (i, element) ->
      res = Parser.singleObj Parser.context(@), obj
      result.push res if res
    result

  parse   : ($, rule)  ->
    log "parse: ", typeof $.find
    # if rule has property 'key' create a list of object of each result
    return Parser.string $, selector: rule[0], list: true if Array.isArray rule
    return Parser.string $, selector: rule, single: true if typeof rule is 'string'
    return Parser.obj $, rule if rule.hasOwnProperty "rules"
    Parser.string $, rule

parser = (html, rule) ->
  log 'Running parser through ' + html.length + 'bytes'
  $ = Parser.context html
  Parser.parse $, rule

module.exports = parser




