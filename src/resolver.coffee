$RefParser  = require 'json-schema-ref-parser'
MeshbluHttp = require 'browser-meshblu-http'
URL         = require 'url'
_           = require 'lodash'

class MeshbluJsonSchemaResolver
  constructor: ({meshbluConfig}) ->
    @meshblu = new MeshbluHttp meshbluConfig

  resolve: (schema, callback) =>
    resolvers =
      meshbludevice:
        canRead: /^meshbludevice:/i,
        read: @_readMeshbluDevice

    $RefParser.dereference schema, {resolve: resolvers}, callback

  _readMeshbluDevice: ({url}, callback) =>
    parsedUrl = URL.parse url
    deviceUuid = _.trim parsedUrl.path, '/'
    @meshblu.device deviceUuid, callback
    
    return

module.exports = MeshbluJsonSchemaResolver
