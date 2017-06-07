$RefParser  = require 'json-schema-ref-parser'
MeshbluHttp = require 'browser-meshblu-http'
URL         = require 'url-parse'

#It's dumb, but it saves 80k!
trim      = require 'lodash/trim'
isEmpty   = require 'lodash/isEmpty'
cloneDeep = require 'lodash/cloneDeep'
_         = {trim, isEmpty, cloneDeep}

class MeshbluJsonSchemaResolver
  constructor: ({meshbluConfig}) ->
    @meshblu = new MeshbluHttp meshbluConfig

  resolve: (schema, callback) =>
    schema = _.cloneDeep schema
    resolvers =
      file: false
      http:
        timeout: 15000
      meshbludevice:
        canRead: /^meshbludevice:/i,
        read: @_readMeshbluDevice
    $RefParser.dereference schema, {resolve: resolvers}, callback
    return # stupid promises

  _readMeshbluDevice: ({url}, callback) =>
    options = {}
    parsedUrl = new URL url
    deviceUuid = _.trim(parsedUrl.pathname, '/') || parsedUrl.host
    options.as = parsedUrl.auth unless _.isEmpty parsedUrl.auth
    @meshblu.device deviceUuid, options, (error, device) =>
      if error?
        error.uuid = deviceUuid
        error.as = options.as
      callback error, device
    return # stupid promises

module.exports = MeshbluJsonSchemaResolver
