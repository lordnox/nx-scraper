
nock    = require 'nock'

fixtures =
  host  : 'http://example.com'
  url   : 'http://example.com/test-page.html'
  get   : '/test-page.html'

describe "Scraper", ->

  Scraper         = require "../app/scraper"

  describe "basics", ->
    scraper = null

    beforeEach ->
      scraper = Scraper fixtures.url, hash: true

    it "should be a module function", ->
      Scraper.should.be.a.function

    it "should return an instance of Scraper without 'new'", ->
      scraper.should.be.instanceof Scraper

    it "should have setup defaults values for the options", ->
      {options} = scraper
      options.should.have.property 'hash'
      options.hash.should.be.equal true
      options.should.have.property 'method'
      options.method.should.be.equal 'GET'
      options.should.have.property 'hashFn'
      options.hashFn.should.be.equal 'sha512'
      options.should.have.property 'hashDigest'
      options.hashDigest.should.be.equal 'hex'

    it "should have a scrape method", ->
      scraper.should.have.property 'scrape'
      scraper.scrape.should.be.a.Function

    it "should request the url when scrape is called", (done) ->
      fix =
        body: '<div>TEST</div>'
        hash: 'd7a5e5df781f81860827e37a509bc36a2a77a68ef4f756b90054b83b168f817c6c365ef1cd14354064071e18939da4fdf5dd4e2f10f974dfb7d343d52106a2dd'
      nock(fixtures.host).get(fixtures.get).times(1).reply 200, fix.body
      scraper.scrape (err, data, hash) ->
        hash.should.be.equal fix.hash
        data.should.be.eql fix.body
        done()

    it "should emit an event if no callback was given", (done) ->
      fix =
        body: '<div>TEST</div>'
        hash: 'd7a5e5df781f81860827e37a509bc36a2a77a68ef4f756b90054b83b168f817c6c365ef1cd14354064071e18939da4fdf5dd4e2f10f974dfb7d343d52106a2dd'
      nock(fixtures.host).get(fixtures.get).times(1).reply 200, fix.body
      scraper.on 'scraped',  ({data, hash}) ->
        hash.should.be.equal fix.hash
        data.should.be.eql fix.body
        done()
      scraper.scrape()

    it "the event should not be emitted when the callback is available", -> (done) ->
      fix =
        body: '<div>TEST</div>'
        called: 0
      nock(fixtures.host).get(fixtures.get).times(1).reply 200, fix.body
      scraper.on 'scraped',  ->
        fix.called++
      scraper.scrape ->
        fix.called.should.be.equal 0

