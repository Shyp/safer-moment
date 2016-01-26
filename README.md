# Safer Moment

This library is designed to allow safer use of [Moment.js][moment].
Specifically, it's easy to parse/create invalid dates and do addition on them
without realizing that they're invalid. This can lead to failures far from the
source of truth.

A secondary concern when working with Unix timestamps is to ask Moment to parse
milliseconds instead of seconds; this will lead to you working with time in the
year 33000.

[moment]: http://momentjs.com/docs/

The library has five functions:

- `Moment.parse(timeStr, format)` - Parse the `timeStr` using the given
  `format` string (or null, to use Moment's default parsing). Throws an Error
  if the `timeStr` is invalid.

- `Moment.parseOrNow(timeStr, format)` - Parse the `timeStr` using the given
  `format` string (or null, to use Moment's default parsing). If the `timeStr`
  is invalid, return a Moment object representing the current time.

- `Moment.isValid(val)` - Returns true if `val` is parseable as a valid Moment
  object. This parser is slightly stricter than moment's in two ways:

  - moment will accept input values like 1, but we reject them and any values
    that are too old or too far in the future. Specifically, the year that
    would be generated for the moment object should fall in the range 1995 to
    2025.

  - `moment(undefined)` returns the current time, but
  `Moment.isValid(undefined)` assumes the caller has a data issue and will
  return false.

- `Moment.parseUnix(timestamp)` - Parse the given Unix timestamp (number of
  seconds since the epoch) as a Moment object. Throws a ValueError if the result
  is unparseable.

  This will also throw an error if you pass a value in milliseconds instead
  of seconds; this is done by attempting to parse the timestamp and throwing
  an error if the parsed year is greater than 3000. Hopefully programmers
  in the year 3000 are using something better than Javascript.

  NB: due to the confusion between second/millisecond timestamps, and confusion
  about the timezone represented by an integer, you probably shouldn't be using
  this; prefer ISO 8601 date times instead. But you may have legacy code that
  works with timestamps.

- `Moment.now()` - Return the current time.

## Installation

Copy Moment.coffee into your source tree. You might need to take a dependency
on coffee-script; if there's interest, we could compile this to Javascript and
check that in instead.

## Dependencies

This library depends on `moment`, version 2.8.2, and `moment-timezone`, version
0.2.1. We haven't evaluated compatibility with other versions; you should
evaluate this for yourself.

## Running the tests

Run `make test-install test` and you should get the tests running.
