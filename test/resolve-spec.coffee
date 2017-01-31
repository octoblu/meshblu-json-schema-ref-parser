MeshbluJsonSchemaResolver = require '../src/resolver.coffee'
shmock = require 'shmock'
enableDestroy = require 'server-destroy'

describe 'MeshbluJsonSchemaResolver', ->
  beforeEach 'start Meshblu', (done) ->
    @meshblu = shmock done
    enableDestroy @meshblu

  afterEach 'destroy Meshblu', (done) ->
    @meshblu.destroy done

  context 'Created with a meshbluConfig', ->
    beforeEach ->
      meshbluConfig =
        hostname: '127.0.0.1'
        port: @meshblu.address().port
        protocol: 'http'
        uuid: 'a-uuid'
        token: 'super-secret'

      @sut = new MeshbluJsonSchemaResolver {meshbluConfig}

    it 'should exist', ->
      expect(@sut).to.exist

    context 'When resolving a schema', ->
      beforeEach (done) ->
        @whateverSchema =
          type: 'object'
          properties:
            name:
              type: 'string'
            description:
              type: 'string'

        @sut.resolve @whateverSchema, (error, @resolvedSchema) => done(error)

      it 'should give us back the schema', ->
        expect(@resolvedSchema).to.deep.equal @whateverSchema

    context 'When resolving a schema with a reference', ->
      beforeEach 'start static file server', (done) ->
        @ref1Schema =
          type: 'number'
          description: '?'

        @staticFileServer = shmock done
        @staticFileServer
          .get '/schema/ref1'
          .reply 200, @ref1Schema
        enableDestroy @staticFileServer

      afterEach 'destroy Meshblu', (done) ->
        @staticFileServer.destroy done

      beforeEach (done) ->
        whateverSchema =
          type: 'object'
          properties:
            name:
              $ref: "http://127.0.0.1:#{@staticFileServer.address().port}/schema/ref1"
            description:
              type: 'string'

        @sut.resolve whateverSchema, (error, @resolvedSchema) => done(error)

      it 'should give us back the schema', ->
        expect(@resolvedSchema.properties.name).to.deep.equal @ref1Schema

    context 'When resolving a schema with a reference to a meshblu device property', ->
      beforeEach 'meshblu device', ->
        aDevice =
          some:
            property:
              type: 'object'
              properties:
                color:
                  type: 'string'
        @meshblu
          .get '/v2/devices/a-device-uuid'
          .reply 200, aDevice


      beforeEach (done) ->

        whateverSchema =
          type: 'object'
          properties:
            name:
              $ref: "meshbludevice://127.0.0.1:#{@meshblu.address().port}/a-device-uuid/#/some/property"
            description:
              type: 'string'

        @sut.resolve whateverSchema, (error, @resolvedSchema) => done(error)

      it 'should give us back the schema', ->
        propertySchema =
          type: 'object'
          properties:
            color:
              type: 'string'

        expect(@resolvedSchema.properties.name).to.deep.equal propertySchema


    context 'When resolving a schema with a reference to a meshblu device property and an "as" property', ->
      beforeEach 'meshblu device', ->
        aDevice =
          some:
            property:
              type: 'object'
              properties:
                color:
                  type: 'string'
        @meshblu
          .get '/v2/devices/a-device-uuid'
          .set 'x-meshblu-as', '5'
          .reply 200, aDevice


      beforeEach (done) ->

        whateverSchema =
          type: 'object'
          properties:
            name:
              $ref: "meshbludevice://5@127.0.0.1:#{@meshblu.address().port}/a-device-uuid/#/some/property"
            description:
              type: 'string'

        @sut.resolve whateverSchema, (error, @resolvedSchema) => done(error)

      it 'should give us back the schema', ->
        propertySchema =
          type: 'object'
          properties:
            color:
              type: 'string'

        expect(@resolvedSchema.properties.name).to.deep.equal propertySchema
