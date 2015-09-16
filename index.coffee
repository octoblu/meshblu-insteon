'use strict';
util           = require 'util'
{EventEmitter} = require 'events'
debug          = require('debug')('meshblu-insteon:index')
{Insteon}      = require 'home-controller'
DefaultOptions = require './default-options.coffee'

MESSAGE_SCHEMA =
  type: 'object'
  properties:
    on:
      type: 'boolean'
      required: true
    deviceId:
      type: 'string'
      required: true
    brightness:
      type: 'number'
      required: false

OPTIONS_SCHEMA =
  type: 'object'
  properties:
    ipAddress:
      type: 'string'
      required: true
    portNumber:
      type: 'number'
      required: false

class Plugin extends EventEmitter
  constructor: ->
    debug 'starting plugin'
    @options = {}
    @messageSchema = MESSAGE_SCHEMA
    @optionsSchema = OPTIONS_SCHEMA
    @defaultOptions = new DefaultOptions

  getDefaultOptions: (callback=->) =>
    debug 'getting default options'
    if @options.ipAddress && @options.portNumber
      config = ipAddress: @options.ipAddress, portNumber: @options.portNumber
      return callback null, config
    @defaultOptions.get (error, options) =>
      return callback error if error?
      @options.ipAddress = options.ipAddress
      @options.portNumber = options.portNumber
      config = ipAddress: @options.ipAddress, portNumber: @options.portNumber
      @emit 'update', config
      return callback null, config

  connect: (callback=->) =>
    debug 'connecting...', @gateway?
    return callback() if @gateway
    @gateway = new Insteon

    @gateway.on 'error', (error) =>
      console.error 'Insteon Gateway error', error
    @gateway.on 'close', (error) =>
      console.error 'Insteon Gateway closed', error

    @getDefaultOptions (error, options) =>
      return callback error if error?
      @gateway.connect options.ipAddress, options.portNumber, callback

  onMessage: (message={}) =>
    payload = message.payload ? message.message ? {}
    debug 'onMessage', payload
    payload.brightness ?= 100
    payload.on ?= false

    closeGateway = =>
      debug 'changed light'
      @gateway.close()

    closeWithError = (error) =>
      console.error 'error changing light', error
      closeGateway()

    @connect (error) =>
      return console.error error if error?
      light = @gateway.light payload.deviceId
      light.turnOff().then closeGateway, closeWithError unless payload.on
      light.turnOn(payload.brightness).then closeGateway, closeWithError if payload.on

  onConfig: (device) =>
    debug 'on config', device.options
    @setOptions device.options

  setOptions: (options={}) =>
    return if options.ipAddress == @options.ipAddress
    return if options.portNumber == @options.portNumber
    @options = options
    @options.portNumber ?= 9761
    @gateway = null
    @onMessage on: true

module.exports =
  messageSchema: MESSAGE_SCHEMA
  optionsSchema: OPTIONS_SCHEMA
  Plugin: Plugin
