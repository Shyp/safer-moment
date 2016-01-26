# Moment is a wrapper around the `moment` library, designed to allow for safe
# execution. Specifically, if you pass an invalid date to `moment()`, no errors
# will be thrown, and calls to `.add()` / `.subtract()` etc won't error. Moment
# will always return you a valid moment object or throw an error, so if you get
# a `moment` object back you will know it's valid.
moment = require 'moment-timezone'

# Raised when an argument has the right type, but an inappropriate value.
class ValueError
  # `message`: Human-readable error message. Should fit in the alert box on
  #   a phone
  # `id`: A unique identifier for the error, should be a string in CODES
  #
  # Optional params (pass in the `opts` dictionary):
  #
  # `detail`: More description about the item that could not be found. May be
  #   returned in the API response, but will not be visible on phones.
  # `instanceUrl`: Link to the instance that could not be found. Should be
  #   relative to api.shyp.com, e.g. "/pickups/pik_123"
  constructor: (message, id) ->
    unless @ instanceof ValueError
      return new ValueError(message, id)

    @id          = id
    @message     = message

    Error.call(@)
    Error.captureStackTrace(@, arguments.callee)
    @name = @constructor.name

  @:: = Object.create Error::
  @::constructor = ValueError

MIN_VALID_YEAR = 1995
MAX_VALID_YEAR = 2025

module.exports = Moment =

  # Parse the given timeStr into a Moment object. Returns the valid moment
  # object, or throws an error if it could not be parsed.
  #
  # `timeStr`: A string to be parsed into a Moment object, for example '2006-01-02T15:04:05-07:00'
  # `format`: A format to parse the string with, for example 'YYYY-MM-DD'.
  #   For valid format strings see http://momentjs.com/docs/#/parsing/string-format/
  parse: (timeStr, format) ->
    if timeStr
      m = moment(timeStr, format)
    unless m and m.isValid()
      throw new ValueError "Couldn't parse '#{timeStr}' as a date", 'invalid_date'
    return m

  # isValid returns true if `val` is parseable as a Moment object. This parser
  # is slightly stricter than moment's in two ways:
  #
  # - moment will accept input values like 1, but we reject them and any values
  #   that are too old or too far in the future. Specifically, the year that
  #   would be generated for the moment object should fall in the range 1995 to
  #   2025.
  # - moment(undefined) returns the current time, but Moment.isValid(undefined)
  #   assumes the caller has a data issue and will return false.
  isValid: (val, format) ->
    unless val?
      return false
    m = moment(val, format)
    unless m.isValid()
      return false
    year = m.year()
    return year >= MIN_VALID_YEAR and year <= MAX_VALID_YEAR


  # ParseUnix will parse the given Unix timestamp as a Moment object. Throws a
  # ValueError if the result is unparseable.
  #
  # This will also throw an error if you pass a value in milliseconds instead
  # of seconds; this is done by attempting to parse the timestamp and throwing
  # an error if the parsed year is greater than 3000. Hopefully programmers
  # in the year 3000 are using something better than Javascript.
  #
  # NB: we should not be calling this function for new code, due to the
  # confusion between second/millisecond timestamps, and confusion about the
  # timezone represented by an integer. Prefer ISO 8601 date times instead.
  #
  # `timestamp`: Number of seconds since the Unix epoch, as an integer.
  parseUnix: (timestamp) ->
    m = moment.unix(timestamp)
    unless m.isValid()
      throw new ValueError "Couldn't parse '#{timestamp}' as a date", 'invalid_date'
    if m.year() > 3000
      throw new ValueError 'parseUnix: Invalid timestamp (possibly using
        milliseconds instead of seconds)', 'invalid_date'
    return m

  # parseOrNow attempts to parse the given timeStr with the given format (or
  # Moment's default parser, if unprovided). If the input cannot be parsed,
  # `parseOrNow` will return a Moment object with the current time.
  parseOrNow: (timeStr, format) ->
    try
      Moment.parse timeStr, format
    catch err
      unless err instanceof ValueError and err.id is 'invalid_date'
        throw err
      return Moment.now()

  # Returns the current time as a moment object. Useful for stubbing out the
  # current time in tests.
  now: ->
    return moment()

Moment.ValueError = ValueError
