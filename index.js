var util = require('util');
var EventEmitter = require('events').EventEmitter;
var Plugin = require('skynet-insteon').Plugin;

util.inherits(Plugin, EventEmitter);

module.exports = {
  Plugin: Plugin
};
