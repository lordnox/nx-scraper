
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

    it "should find two tags identified by class", ->
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
        html  : "<div class='here'>Text A</div>"
        res   : ["Text A"]
        rules : { selector: ".here" }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should only find the first hit and return no array if it has a single option", ->
      fix =
        html  : "<div class='here'>Text A</div>"
        res   : "Text A"
        rules : { selector: ".here", single: true }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should find both tags", ->
      fix =
        html  : "<div>A</div><div>B</div>"
        res   : ["A", "B"]
        rules : { selector: "div" }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should find only the first tag", ->
      fix =
        html  : "<div>A</div><div>B</div>"
        res   : "A"
        rules : { selector: "div", single: true }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should find only the last tag", ->
      fix =
        html  : "<span><div>A</div><div>B</div></span>"
        res   : "B"
        rules : { selector: "div+div", single: true }
      fix.res.should.be.eql parser fix.html, fix.rules


  describe "string-shorthand", ->
    it "should parse a string as a selector/single rule", ->
      fix =
        html  : "<div class='here'>Text A</div>"
        res   : "Text A"
        rules : ".here"
      fix.res.should.be.eql parser fix.html, fix.rules

  describe "object parsing", ->
    it "should return an object", ->
      fix =
        html  : "<div><div class='here'>Text A</div></div>"
        res   : [ { name: ["Text A"] } ]
        rules : { selector: "div.here", rules: { name: { selector: "div" } } }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should return an user object", ->
      fix =
        html  : "<div class='user'><div class='surname'>Martin</div> ... <div class='lastname'>Cheese</div></div>"
        res   : [ { surname: 'Martin', lastname: 'Cheese' } ]
        rules : { selector: ".user", rules: { surname: '.surname', lastname: '.lastname' } }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should return three users", ->
      fix =
        html  : "<ul><li><div>u1.surname</div><div>u1.lastname</div></li><li><div>u2.surname</div><div>u2.lastname</div></li><li><div>u3.surname</div><div>u3.lastname</div></li></ul>"
        res   : [
          surname: 'u1.surname'
          lastname: 'u1.lastname'
        ,
          surname: 'u2.surname'
          lastname: 'u2.lastname'
        ,
          surname: 'u3.surname'
          lastname: 'u3.lastname'
        ]
        rules : { selector: "li", rules: { surname: 'div:nth-child(1)', lastname: 'div:nth-last-child(1)' } }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should only return the first user", ->
      fix =
        html  : "<ul><li><div>u1.surname</div><div>u1.lastname</div></li><li><div>u2.surname</div><div>u2.lastname</div></li><li><div>u3.surname</div><div>u3.lastname</div></li></ul>"
        res   :
          surname: 'u1.surname'
          lastname: 'u1.lastname'
        rules : { selector: "li", single: true, rules: { surname: 'div:nth-child(1)', lastname: 'div:nth-last-child(1)' } }
      fix.res.should.be.eql parser fix.html, fix.rules

    it "should only return the second user", ->
      fix =
        html  : "<ul><li><div>u1.surname</div><div>u1.lastname</div></li><li><div>u2.surname</div><div>u2.lastname</div></li><li><div>u3.surname</div><div>u3.lastname</div></li></ul>"
        res   :
          surname: 'u2.surname'
          lastname: 'u2.lastname'
        rules : { selector: "li:nth-child(2)", single: true, rules: { surname: 'div:nth-child(1)', lastname: 'div:nth-last-child(1)' } }
      fix.res.should.be.eql parser fix.html, fix.rules

  describe "chaining", ->
    fix = null

    beforeEach ->
      fix =
        html: "<div class='user'><div class='name'><div class='surname'>SURNAME</div><div class='lastname'>LASTNAME</div></div></div>"

    afterEach ->
      res = parser fix.html, fix.rules
      res.should.be.eql fix.res

    it "should find the 3rd-depth div", ->
      fix.rules = { selector: "div>div>div" }
      fix.res   = [
        "SURNAME"
        "LASTNAME"
      ]

    it "should find the surname via class", ->
      fix.rules = { selector: ".surname" }
      fix.res   = [
        "SURNAME"
      ]

    it "should find the surname via class and shorthand", ->
      fix.rules = ".surname"
      fix.res   = "SURNAME"

    it "should find the user with a surname property", ->
      fix.rules =
        selector: '.user'
        rules:
          surname: '.surname'
      fix.res = [
        surname: 'SURNAME'
      ]

    it "should find the name with surname and lastname property", ->
      fix.rules =
        selector: '.name'
        rules:
          surname: '.surname'
          lastname: '.lastname'
      fix.res = [
        surname: 'SURNAME'
        lastname: 'LASTNAME'
      ]

    it "should find users with names", ->
      fix.rules =
        selector: '.user'
        rules:
          name:
            selector: '.name'
            rules:
              surname: '.surname'
              lastname: '.lastname'
      fix.res = [
        name: [
          surname: 'SURNAME'
          lastname: 'LASTNAME'
        ]
      ]

    it "should find users with a name", ->
      fix.rules =
        selector: '.user'
        rules:
          name:
            selector: '.name'
            single: true
            rules:
              surname: '.surname'
              lastname: '.lastname'
      fix.res = [
        name:
          surname: 'SURNAME'
          lastname: 'LASTNAME'
      ]

    it "should find a user with a name", ->
      fix.rules =
        selector: '.user'
        single: true
        rules:
          name:
            selector: '.name'
            single: true
            rules:
              surname: '.surname'
              lastname: '.lastname'
      fix.res =
        name:
          surname: 'SURNAME'
          lastname: 'LASTNAME'











