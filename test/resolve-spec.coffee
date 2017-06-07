{describe,beforeEach,afterEach,it} = global
{expect}                  = require 'chai'
shmock                    = require 'shmock'
enableDestroy             = require 'server-destroy'
MeshbluJsonSchemaResolver = require '../src/resolver.coffee'

describe 'MeshbluJsonSchemaResolver', ->
  beforeEach 'start Meshblu', ->
    @meshblu = shmock()
    enableDestroy @meshblu

  afterEach 'destroy Meshblu', (done) ->
    @meshblu.destroy done

  describe 'Created with a meshbluConfig', ->
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

    describe 'When resolving a schema', ->
      beforeEach 'waiting to resolve', (done) ->
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

    describe 'When resolving a schema with a file reference ', ->
      beforeEach 'waiting to resolve', (done) ->
        @whateverSchema =
          type: 'object'
          properties:
            name:
              type: 'string'
            description:
              type:
                $ref: '/etc/passwd'

        @sut.resolve @whateverSchema, (@error, @resolvedSchema) => done()

      it 'should not give us back /etc/passwd', ->
        expect(@error).to.exist

    describe 'When resolving a schema with a reference', ->
      beforeEach 'start static file server', ->
        @ref1Schema =
          type: 'number'
          description: '?'

        @staticFileServer = shmock()
        @staticFileServer
          .get '/schema/ref1'
          .reply 200, @ref1Schema
        enableDestroy @staticFileServer

      afterEach 'destroy Meshblu', (done) ->
        @staticFileServer.destroy done

      beforeEach 'do the thing', (done) ->
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

    describe 'When resolving a schema with a reference to a meshblu device property', ->
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


    describe 'When resolving a schema with a reference to a meshblu device property and an "as" property', ->
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

    describe 'When resolving a schema with a reference to a meshblu device property', ->
      beforeEach 'meshblu device', ->
        @meshblu
          .get '/v2/devices/a-device-uuid'
          .set 'x-meshblu-as', '5'
          .reply 200, {
            shouldNotEndUpOnOriginalDevice: true
          }

      beforeEach (done) ->
        @whateverSchema =
          type: 'object'
          properties:
            name:
              $ref: "meshbludevice://5@127.0.0.1:#{@meshblu.address().port}/a-device-uuid"
            description:
              type: 'string'

        @sut.resolve @whateverSchema, (error, @resolvedSchema) =>
          done(error)

      it 'should not mutate whateverSchema', ->
        expect(@whateverSchema).to.deep.equal
          type: 'object'
          properties:
            name:
              $ref: "meshbludevice://5@127.0.0.1:#{@meshblu.address().port}/a-device-uuid"
            description:
              type: 'string'
