chai = require "chai"
should = chai.should()
samjs = require "samjs"
samjsClient = require "samjs-client"
pluginBoilerplate = require("../src/main")(samjs)
pluginBoilerplateClient = require "samjs-plugin-boilerplate-client"
fs = samjs.Promise.promisifyAll(require("fs"))
port = 3040
url = "http://localhost:"+port+"/"
testConfigFile = "test/testConfig.json"

describe "samjs", ->
  client = null
  before (done) ->
    samjs.reset().plugins(pluginBoilerplate)
    fs.unlinkAsync testConfigFile
    .catch -> return true
    .finally ->
      done()

  describe "object", ->
    it "should be accessible", ->
      samjs[pluginBoilerplate.name].someFunc().should
      .equal "will be accessibly under samjs.pluginBoilerplate.someFunc"
  describe "options", ->
    it "should have defaults", ->
      samjs.options({config:testConfigFile})
      samjs.options["default-option"].should
      .equal "will be set only if not already set"
  describe "configs", ->
    opt = null
    it "should have defaults", ->
      samjs.configs()
      opt = samjs.configs["default-config"]
      should.exist opt
    it "should reject get", (done) ->
      opt.get()
      .catch -> done()
    it "should reject set", (done) ->
      opt.set()
      .catch -> done()
    it "should reject test", (done) ->
      opt.test()
      .catch -> done()
  describe "models", ->
    it "should have defaults", ->
      samjs.models()
      should.exist samjs.models["default-model"]
      should.exist samjs.models["default-model-required"]
  describe "startup", ->
    it "should configure", (done) ->
      samjs.startup().io.listen(port)
      client = samjsClient({
        url: url
        ioOpts:
          reconnection: false
          autoConnect: false
        })()
      client.install.onceConfigure
      .return client.install.set "default-config", "correct"
      .then -> done()
      .catch done
    it "should install", (done) ->
      client.plugins(pluginBoilerplateClient)
      client.install.onceInstall
      .return client.boilerplate.install "rightValue"
      .then -> done()
      .catch done
    it "should have startup called after install", ->
      pluginBoilerplate.startupCalled.should.be.true
    it "should have model startup called after install", ->
      samjs.models["default-model"].startupCalled.should.be.true
    it "should connect to interfaces", (done) ->
      client.boilerplate.get()
      .catch (e) ->
        e.message.should.equal "denied"
        client.boilerplate.auth()
      .then (response) ->
        response.should.equal "success"
        client.boilerplate.get()
      .then (response) ->
        response.should.equal "someValue"
        done()
      .catch done
    it "should have shutdown called after shutdown", (done) ->
      samjs.shutdown().then ->
        pluginBoilerplate.shutdownCalled.should.be.true
        done()
