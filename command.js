var Plugin = require('./index').Plugin;
var skynet = require('skynet');
var config = require('./meshblu.json');

var conx = skynet.createConnection({
  server : config.server,
  port   : config.port,
  uuid   : config.uuid,
  token  : config.token
});

conx.on('notReady', console.error);
conx.on('error', console.error);

var plugin = new Plugin();
conx.on('message', function(){
  try {
    plugin.onMessage.apply(plugin, arguments);
  } catch (error){
    console.error(error.message);
    console.error(error.stack);
  }
});