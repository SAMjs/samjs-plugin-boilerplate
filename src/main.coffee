# out: ../lib/main.js
module.exports = (samjs) ->
  plugin = {}
  plugin.name = "plugin-boilerplate"
  plugin.obj =
    someFunc: ->
      "will be accessibly under samjs.plugin-boilerplate.someFunc"
  plugin.options =
    "default-option":
      "will be set only if not already set"
  plugin.configs =
    defaults: [{
      name: "default-config"
      isRequired: true
      test: (value) ->
        return samjs.Promise.resolve() if value == "correct"
        return samjs.Promise.reject() if value != "correct"
      },{
      name: "some-other-config"
      }]
    mutator: (options) ->
      plugin.mutatorCalled = true
      # will be called before each config constructor to change the options obj
      return options
    get: (socket) ->
      # will be called when a config is requested by a client
      throw new Error "forbidden" unless socket?.authenticated
    set: (newData, socket) ->
      # will be called when a config should be set by a client
      throw new Error "forbidden" unless socket?.authenticated
      # the config test function will be called with newData afterwards
      return newData
    test: (newData, socket) ->
      # will be called when a config should be tested by a client
      throw new Error "forbidden" unless socket?.authenticated
      return newData
  plugin.models = [
    {
      name: "default-model"
      value: "someValue" # not required
      interfaces:
        auth: (socket) ->
          # will be bound to model instance
          # socket will live in
          # socket-io 'plugin-boilerplate-default-modelModel' namespace
          socket.on "auth", (request)->
            if request.token?
              socket.client.auth = true
              response = success:true, content: "success"
              socket.emit "auth.#{request.token}", response
        boilerplate: (socket) ->
          socket.on "get", (request) =>
            if request.token?
              if socket.client.auth
                response = success:true, content: @value
              else
                response = success:false, content: "denied"
              socket.emit "get.#{request.token}", response
      isExisting: ->
        return false # should return false if model should be inserted
      startup: ->
        @startupCalled = true
    },{
      name: "default-model-required"
      value: "someValue" # not required
      interfaces: boilerplate2: (->)
      isRequired: true
      isExisting: ->
        return false # should return false if model should be inserted
      installInterface: (socket) ->
        # will be bound to model instance
        # socket will live in
        # socket-io 'install' namespace, so specific listeners are required
        socket.on "boilerplate.set", (request) =>
          if request.token? and request.content?
            # no authentification, will be only accessible in install mode
            @test(request.content)
            .then (value) => @value = value
            .then (value)-> success:true, content: value
            .catch (e) -> success:false, content: e.message
            .then (response) ->
              socket.emit "boilerplate.set.#{request.token}", response
              if response.success
                samjs.emit "checkInstalled"
        return -> socket.removeAllListeners "boilerplate.set"
      test: (value=@value) ->
        # will be bound to model instance
        if value == "rightValue"
          return samjs.Promise.resolve(value)
        else
          return samjs.Promise.reject()
    }
  ]
  plugin.startup = ->
    #will be called on samjs.startup, after install
    plugin.startupCalled = true
    return samjs.Promise.resolve()
  plugin.shutdown = ->
    #will be called on samjs.shutdown
    plugin.shutdownCalled = true
    return samjs.Promise.resolve()
  return plugin
