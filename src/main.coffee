# out: ../lib/main.js
module.exports = (samjs) ->
  debug = samjs.debug("pluginBoilerplate")
  debug("some text") # will be available with ENV DEBUG=samjs:pluginBoilerplate
  return new class Plugin
    constructor: ->
      # do something
    name: "pluginBoilerplate"
    someFunc: ->
      "will be accessibly under samjs.pluginBoilerplate.someFunc"
    options:
      "default-option":
        "will be set only if not already set"
    configs: [{
      name: "default-config"
      isRequired: true
      read: false
      write: false
      test: (value) ->
        return samjs.Promise.resolve() if value == "correct"
        return samjs.Promise.reject() if value != "correct"
      hooks:
        before_Set: ({data,oldData}) ->
          # will be called only for this config item
          return {data,oldData}
    },{
      name: "some-other-config"
      }]
    hooks:
      configs:
        before_Set: ({data,oldData}) ->
          # will be called for all config items
          return {data,oldData}
    models: [{
      name: "default-model"
      value: "someValue" # not required
      interfaces:
        auth: (socket) ->
          # this will be bound to model instance
          # socket will live in socket-io 'auth' namespace
          socket.on "auth", (request) ->
            if request.token?
              socket.client.auth = true
              response = success:true, content: "success"
              socket.emit "auth.#{request.token}", response
        boilerplate: (socket) ->
          # socket will live in socket-io 'boilerplate' namespace
          socket.on "get", (request) =>
            if request.token?
              if socket.client.auth
                response = success:true, content: @value
              else
                response = success:false, content: "denied"
              socket.emit "get.#{request.token}", response
      startup: ->
        @startupCalled = true
    },{
      name: "default-model-required"
      value: "someValue" # not required
      isRequired: true
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
                samjs.state.checkInstalled()
        return -> socket.removeAllListeners "boilerplate.set"
      test: (value=@value) ->
        # will be bound to model instance
        if value == "rightValue"
          return samjs.Promise.resolve(value)
        else
          return samjs.Promise.reject()
      }
    ]
    startup: ->
      #will be called on samjs.startup, after install
      @startupCalled = true
      return samjs.Promise.resolve()
    shutdown: ->
      #will be called on samjs.shutdown
      @shutdownCalled = true
      return samjs.Promise.resolve()
