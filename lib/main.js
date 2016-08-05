(function() {
  module.exports = function(samjs) {
    var Plugin, debug;
    debug = samjs.debug("pluginBoilerplate");
    debug("some text");
    return new (Plugin = (function() {
      function Plugin() {}

      Plugin.prototype.name = "pluginBoilerplate";

      Plugin.prototype.someFunc = function() {
        return "will be accessibly under samjs.pluginBoilerplate.someFunc";
      };

      Plugin.prototype.options = {
        "default-option": "will be set only if not already set"
      };

      Plugin.prototype.configs = [
        {
          name: "default-config",
          isRequired: true,
          read: false,
          write: false,
          test: function(value) {
            if (value === "correct") {
              return samjs.Promise.resolve();
            }
            if (value !== "correct") {
              return samjs.Promise.reject();
            }
          },
          hooks: {
            before_Set: function(arg) {
              var data, oldData;
              data = arg.data, oldData = arg.oldData;
              return {
                data: data,
                oldData: oldData
              };
            }
          }
        }, {
          name: "some-other-config"
        }
      ];

      Plugin.prototype.hooks = {
        configs: {
          before_Set: function(arg) {
            var data, oldData;
            data = arg.data, oldData = arg.oldData;
            return {
              data: data,
              oldData: oldData
            };
          }
        }
      };

      Plugin.prototype.models = [
        {
          name: "default-model",
          value: "someValue",
          interfaces: {
            auth: function(socket) {
              return socket.on("auth", function(request) {
                var response;
                if (request.token != null) {
                  socket.client.auth = true;
                  response = {
                    success: true,
                    content: "success"
                  };
                  return socket.emit("auth." + request.token, response);
                }
              });
            },
            boilerplate: function(socket) {
              return socket.on("get", (function(_this) {
                return function(request) {
                  var response;
                  if (request.token != null) {
                    if (socket.client.auth) {
                      response = {
                        success: true,
                        content: _this.value
                      };
                    } else {
                      response = {
                        success: false,
                        content: "denied"
                      };
                    }
                    return socket.emit("get." + request.token, response);
                  }
                };
              })(this));
            }
          },
          startup: function() {
            return this.startupCalled = true;
          }
        }, {
          name: "default-model-required",
          value: "someValue",
          isRequired: true,
          installInterface: function(socket) {
            socket.on("boilerplate.set", (function(_this) {
              return function(request) {
                if ((request.token != null) && (request.content != null)) {
                  return _this.test(request.content).then(function(value) {
                    return _this.value = value;
                  }).then(function(value) {
                    return {
                      success: true,
                      content: value
                    };
                  })["catch"](function(e) {
                    return {
                      success: false,
                      content: e.message
                    };
                  }).then(function(response) {
                    socket.emit("boilerplate.set." + request.token, response);
                    if (response.success) {
                      return samjs.state.checkInstalled();
                    }
                  });
                }
              };
            })(this));
            return function() {
              return socket.removeAllListeners("boilerplate.set");
            };
          },
          test: function(value) {
            if (value == null) {
              value = this.value;
            }
            if (value === "rightValue") {
              return samjs.Promise.resolve(value);
            } else {
              return samjs.Promise.reject();
            }
          }
        }
      ];

      Plugin.prototype.startup = function() {
        this.startupCalled = true;
        return samjs.Promise.resolve();
      };

      Plugin.prototype.shutdown = function() {
        this.shutdownCalled = true;
        return samjs.Promise.resolve();
      };

      return Plugin;

    })());
  };

}).call(this);
