$RefParser  = require 'json-schema-ref-parser'
MeshbluHttp = require 'browser-meshblu-http'
URL         = require 'url-parse'

#It's dumb, but it saves 80k!
trim        = require 'lodash/trim'
_           = {trim}

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
    parsedUrl = new URL url
    deviceUuid = _.trim(parsedUrl.pathname, '/') || parsedUrl.host

    @meshblu.device deviceUuid, {as: 5}, callback

    return

module.exports = MeshbluJsonSchemaResolver
