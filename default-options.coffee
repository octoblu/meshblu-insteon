cheerio     = require 'cheerio'
request     = require 'request'
url         = require 'url'
debug       = require('debug')('meshblu-insteon:default-options')

INSTEON_URI = 'http://connect.insteon.com/getinfo.asp'

class DefaultOptions
  getInfo: (callback=->) =>
    request INSTEON_URI, (error, response, body) =>
      debug 'getInfo', error: error, statusCode: response.statusCode, body: body
      return callback error if error?
      return callback body if response.statusCode > 299
      callback null, body

  getInsteonAddressFromBody: (body='', callback=->) =>
    try
      $ = cheerio.load body
      rawInsteonAddress = $('strong a').attr 'href'
      return callback "No Hub Found" unless rawInsteonAddress?
      insteonAddress = url.parse(rawInsteonAddress);
      callback null, insteonAddress
    catch error
      debug 'getInsteonAddressFromBody', error: error
      callback error

  get: (callback=->) =>
    debug 'getting options'
    @getInfo (error, body) =>
      return callback error if error?
      @getInsteonAddressFromBody body, (error, insteonAddress) =>
        debug 'insteonAddress', error: error, insteonAddress: insteonAddress
        return callback error if error?
        return callback "No Hub Found" unless insteonAddress?
        return callback "No Hub Hostname Found" unless insteonAddress.hostname?
        callback null, ipAddress: insteonAddress.hostname, portNumber: 9761

module.exports = DefaultOptions
