$RefParser            = require '@octoblu/json-schema-ref-parser'
MeshbluDeviceResolver = require './src/resolver'

#It's dumb, but it saves 80k!
defaults  = require 'lodash/defaults'
cloneDeep = require 'lodash/cloneDeep'

class MeshbluJsonSchemaResolver
  constructor: (options) ->
    options ?= {}
    { meshbluConfig, skipInvalidMeshbluDevice } = options
    meshbluDeviceResolver = new MeshbluDeviceResolver { meshbluConfig, skipInvalidMeshbluDevice }

    @resolvers =
      file: false
      http:
        timeout: 15000
      meshbludevice: meshbluDeviceResolver

  resolve: (schema, callback) =>
    schema = cloneDeep schema
    $RefParser.dereference schema, { resolve: @resolvers }, callback
    return # stupid promises

module.exports = MeshbluJsonSchemaResolver
