(function() {
  module.exports = function(samjs) {
    var plugin;
    plugin = {};
    plugin.name = "plugin-boilerplate";
    plugin.obj = {
      someFunc: function() {
        return "will be accessibly under samjs.plugin-boilerplate.someFunc";
      }
    };
    plugin.options = {
      "default-option": "will be set only if not already set"
    };
    plugin.configs = {
      defaults: [
        {
          name: "default-config",
          isRequired: true,
          test: function(value) {
            if (value === "correct") {
              return samjs.Promise.resolve();
            }
            if (value !== "correct") {
              return samjs.Promise.reject();
            }
          }
        }, {
          name: "some-other-config"
        }
      ],
      mutator: function(options) {
        plugin.mutatorCalled = true;
        return options;
      },
      get: function(socket) {
        if (!(socket != null ? socket.authenticated : void 0)) {
          throw new Error("forbidden");
        }
      },
      set: function(newData, socket) {
        if (!(socket != null ? socket.authenticated : void 0)) {
          throw new Error("forbidden");
        }
        return newData;
      },
      test: function(newData, socket) {
        if (!(socket != null ? socket.authenticated : void 0)) {
          throw new Error("forbidden");
        }
        return newData;
      }
    };
    plugin.models = [
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
        isExisting: function() {
          return false;
        },
        startup: function() {
          return this.startupCalled = true;
        }
      }, {
        name: "default-model-required",
        value: "someValue",
        interfaces: {
          boilerplate2: (function() {})
        },
        isRequired: true,
        isExisting: function() {
          return false;
        },
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
                    return samjs.emit("checkInstalled");
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
    plugin.startup = function() {
      plugin.startupCalled = true;
      return samjs.Promise.resolve();
    };
    plugin.shutdown = function() {
      plugin.shutdownCalled = true;
      return samjs.Promise.resolve();
    };
    return plugin;
  };

}).call(this);
