
describe "Parser", ->

  parser = require "../app/parser"

  describe "basics", ->

    it "should be a function", ->
      parser.should.be.a.Function

  describe "string parsing", ->
    it "should find single tag", ->
      fix =
        html  : "<div>Text</div>"
        res   : ["Text"]
        rules : { selector: "div" }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should find the tags in one root tag", ->
      fix =
        html  : "<div><div>Text A</div><div>Text B</div></div>"
        res   : ["Text A", "Text B"]
        rules : { selector: "div div" }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should find the tags identified by class", ->
      fix =
        html  : "<div><div class='here'>Text A</div><div><span class='here'>Text B</span></div></div>"
        res   : ["Text A", "Text B"]
        rules : { selector: "div .here" }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should return false if no tag was found", ->
      fix =
        html  : "<div><div class='here'>Text A</div><div><span class='here'>Text B</span></div></div>"
        res   : false
        rules : { selector: "div .not.here" }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should find the tags identified by class", ->
      fix =
        html  : "<div><div class='here'>Text A</div></div>"
        res   : ["Text A"]
        rules : { selector: ".here" }
      fix.res.should.be.eql parser fix.html, fix.rules

  describe "object parsing", ->
    it "should return an object", ->
      fix =
        html  : "<div><div class='here'>Text A</div></div>"
        res   : [ { name: "Text A" }, { name: "Text B" } ]
        rules : { selector: "div", rules: { name: ".here" } }
      fix.res.should.be.eql parser fix.html, fix.rules













