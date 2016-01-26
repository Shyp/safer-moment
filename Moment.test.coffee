moment = require 'moment'
should = require 'should'

Moment = require './Moment.coffee'

describe 'Moment', ->
  describe 'parse', ->
    it 'should be able to parse with the default parsing format', ->
      m = Moment.parse('2006-01-02T15:04:05-07:00')
      m.format().should.equal '2006-01-02T22:04:05+00:00'
      m.isValid().should.equal true

    it 'should accept another Moment object as input', ->
      m = Moment.parse('2006-01-02T15:04:05-07:00')
      Moment.parse(m).valueOf().should.equal m.valueOf()

    it 'should accept a Date object as input', ->
      d = Moment.parse('2006-01-02T15:04:05-07:00').toDate()
      Moment.parse(d).valueOf().should.equal d.valueOf()

    # I want to be able to disable the JS Date fallback, but I'm not sure the
    # library supports it, or indicates that it had to fallback to JS Date,
    # besides emitting the deprecation warning.
    #
    # In the absence of being able to disable it, add tests that it parses
    # correctly.
    it 'should be able to parse JS Date formats', ->
      m = Moment.parse('1')
      m.format().should.equal '2001-01-01T00:00:00+00:00'
      m.isValid().should.equal true

      m2 = Moment.parse(1)
      m2.format().should.equal '1970-01-01T00:00:00+00:00'
      m2.isValid().should.equal true

    it 'should format strings based on the provided format', ->
      m = Moment.parse('2006-01-02', 'YYYY-MM-DD')
      m.format().should.equal '2006-01-02T00:00:00+00:00'
      m.isValid().should.equal true

    it 'should cross over daylight savings time correctly', ->
      m = Moment.parse '2016-03-12T11:50:00-0800' # the day before DST in the US PST
      m.hours().should.eql 19
      m.add(1, 'day').hours().should.eql 19

    it 'should throw an error if the date is null', ->
      Moment.parse.bind(null, null).should.throw Moment.ValueError,
        id:      'invalid_date'
        message: "Couldn't parse 'null' as a date"

    it 'should throw an error if the date is undefined', ->
      Moment.parse.bind(undefined).should.throw Moment.ValueError,
        id:      'invalid_date'
        message: "Couldn't parse 'undefined' as a date"

    it 'should throw an error even if a formatting argument is provided', ->
      Moment.parse.bind(null, null, 'YYYY').should.throw Moment.ValueError,
        message: "Couldn't parse 'null' as a date"

    it 'should throw an error if the date is a bad string', ->
      Moment.parse.bind(null, 'foo').should.throw Moment.ValueError,
        message: "Couldn't parse 'foo' as a date"

  describe 'parseUnix', ->
    it 'should parse Unix timestamps in seconds', ->
      m = Moment.parseUnix(1136239445)
      m.format().should.equal '2006-01-02T22:04:05+00:00'

    it 'should throw an error if the timestamp is unparseable', ->
      Moment.parseUnix.bind(null, 1136239445000).should.throw Moment.ValueError,
        message: 'parseUnix: Invalid timestamp (possibly using milliseconds instead of seconds)'

  describe 'parseOrNow', ->
    it 'should parse provided objects', ->
      m = Moment.parseOrNow('2006-01-02')
      m.format().should.equal '2006-01-02T00:00:00+00:00'
      m.isValid().should.equal true

    it 'should parse strings based on the provided format', ->
      m = Moment.parseOrNow('2006-01-02', 'YYYY-MM-DD')
      m.format().should.equal '2006-01-02T00:00:00+00:00'
      m.isValid().should.equal true

    context 'when the input is null', ->
      nowFn = null
      now = null

      beforeEach ->
        now = moment()
        nowFn = Moment.now
        Moment.now = -> now

      it 'should return the current time', ->
        m = Moment.parseOrNow(null, 'YYYY-MM-DD')
        m.format().should.equal now.format()
        m.isValid().should.equal true

      afterEach ->
        Moment.now = nowFn

  describe 'isValid', ->
    it 'should accept JS Date objects as valid', ->
      d = new Date()
      Moment.isValid(d).should.equal true

    it 'should accept valid timestamp strings as valid', ->
      Moment.isValid('2006-01-02', 'YYYY-MM-DD').should.equal true
      Moment.isValid('2006-01-02').should.equal true

    it "should report strings as invalid if they don't match the format", ->
      Moment.isValid('2006-01-02', 'MM-DD').should.equal false

    it 'should report that invalid objects are invalid', ->
      Moment.isValid(null).should.equal false
      Moment.isValid(undefined).should.equal false
      Moment.isValid('foo').should.equal false

    it 'should reject dates that are too far in the past', ->
      Moment.isValid('1994-01-02').should.equal false
      Moment.isValid(1).should.equal false
      Moment.isValid(2000).should.equal false
      Moment.isValid(3000).should.equal false

    it 'should reject dates that are too far in the future', ->
      Moment.isValid('2026-01-02').should.equal false
      Moment.isValid(1448064347915000).should.equal false
