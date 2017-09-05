URL         = require 'url-parse'
MeshbluHttp = require 'browser-meshblu-http'

#It's dumb, but it saves 80k!
trim      = require 'lodash/trim'
isEmpty   = require 'lodash/isEmpty'

class MeshbluDeviceResolver
  constructor: ({ meshbluConfig, @skipInvalidMeshbluDevice }) ->
    @canRead = /^meshbludevice:/i
    @meshblu = new MeshbluHttp meshbluConfig

  read: ({url}, callback) =>
    options = {}
    parsedUrl = new URL url
    deviceUuid = trim(parsedUrl.pathname, '/') || parsedUrl.host
    options.as = parsedUrl.auth unless isEmpty parsedUrl.auth
    @meshblu.device deviceUuid, options, (error, device) =>
      return callback(null, {}) if @skipInvalidMeshbluDevice && error?
      if error?
        error.uuid = deviceUuid
        error.as = options.as
      callback error, device
    return # stupid promises

module.exports = MeshbluDeviceResolver
