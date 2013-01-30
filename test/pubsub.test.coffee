libpath   = if process.env.COVERAGE then "../src-cov" else "../src"
PubSub    = require "#{libpath}/pubsub"

should    = require "should"
assert    = require "assert"

describe "PubSub", ->

  it "should exist", ->
    PubSub.should.be.defined

  describe "#unsubscribe", ->
    it "should link #off to #unsubscribe", ->
      PubSub::off.should.be.equal PubSub::unsubscribe

    it "should clear the state of pubsub when no arguments are given to unsubscribe", ->
      pubsub = new PubSub()
      event  = "i.like.turtles"
      event2 = "hoooleeyyyshiiiett"

      pubsub.subscribe event, ->
      pubsub.subscribe event2, ->

      pubsub._pubsub[event].should.be.instanceOf(Array).with.lengthOf(1)
      pubsub._pubsub[event2].should.be.instanceOf(Array).with.lengthOf(1)

      pubsub.unsubscribe()

      assert typeof pubsub._pubsub[event] is 'undefined'
      assert typeof pubsub._pubsub[event2] is 'undefined'


    it "should remove all callbacks with given event from list if no callback is given", ->
      pubsub = new PubSub()
      event  = "test.event"
      event2 = "test.event.2"
      callb  = ->
      pubsub.subscribe event, callb
      pubsub.subscribe event2, callb

      pubsub._pubsub[event].should.be.instanceOf(Array).with.lengthOf(1)

      pubsub.unsubscribe event
      assert typeof pubsub._pubsub[event] is 'undefined'

      pubsub._pubsub[event2].should.be.instanceOf(Array).with.lengthOf(1)

    it "should remove only the given callback from list", ->
      pubsub = new PubSub()
      event  = "test?event"
      callbacks = {}
      callbacks.one = -> return 'function one'
      callbacks.two = -> return 'function two'
      callbacks.six = -> return 'function six'

      # Add all events to list
      pubsub.subscribe event, callback for own i, callback of callbacks
      pubsub.unsubscribe event, callbacks.two

      pubsub._pubsub[event].should.be.instanceOf(Array).with.lengthOf(2)
      callb = pubsub._pubsub[event].map (obj) -> return obj.callback
      callb.should.include(callbacks.one, callbacks.six)

    it "should remove object with context change from list", ->
      pubsub = new PubSub()
      event  = "test?event"
      callbacks = {}
      callbacks.one = -> return 'function one'
      callbacks.two = -> return 'function two'
      callbacks.six = -> return 'function six'

      # Add all events to list
      pubsub.subscribe event, callback for own i, callback of callbacks
      pubsub.unsubscribe event, callbacks.two

      pubsub._pubsub[event].should.be.instanceOf(Array).with.lengthOf(2)
      callb = pubsub._pubsub[event].map (obj) -> return obj.callback
      callb.should.include(callbacks.one, callbacks.six)

  describe "#subscribe", ->
    it "should link #on to #subscribe", ->
      PubSub::on.should.be.equal PubSub::subscribe

    it "should throw when no callback is defined", ->
      pubsub = new PubSub()
      (-> pubsub.subscribe 'test').should.throw "No callback defined"

    it "should throw when no event is defined", ->
      pubsub = new PubSub()
      (-> pubsub.subscribe undefined, ->).should.throw "No event defined"

    it "should subscribe to pubsub", ->
      pubsub = new PubSub()
      event  = "test.event"
      callb  = ->
      pubsub.subscribe event, callb

      pubsub._pubsub[event].should.be.instanceOf(Array)
                           .with.lengthOf(1)
      pubsub._pubsub[event][0].callback.should.equal(callb)

    it "should subscribe to pubsub with context", (done) ->
      pubsub = new PubSub()
      event  = "test...event"
      testObj=
        'foo' : 'bar'

      callb  = (one, two) ->
        this.foo.should.equal 'bar'
        one.should.equal 'one'
        two.should.equal 'two'
        done()

      pubsub.subscribe event, callb, testObj
      pubsub.publish event, 'one', 'two'

  describe "#publish", ->
    it "should link #trigger to #publish", ->
      PubSub::trigger.should.be.equal PubSub::publish

    it "should throw when no event is defined", ->
      pubsub = new PubSub()
      (-> pubsub.publish undefined).should.throw "No event defined"

    it "should publish events", (done) ->
      pubsub = new PubSub()
      event  = "random..event"
      callb  = (arg) ->
        arg.should.equal('test')
        done()

      pubsub.subscribe event, callb
      pubsub.publish event, 'test'

    it "should publish events without arguments", (done) ->
      pubsub = new PubSub()
      event  = "random..event"
      callb  = ->
        done()

      pubsub.subscribe event, callb
      pubsub.publish event

    it "should publish between multiple receivers", (done) ->
      pubsub = new PubSub()
      event  = "this.is.sparta"
      callbacks = 0
      maxCallbacks = 12

      inc = ->
        callbacks++
        done() if callbacks is maxCallbacks

      for i in [0..maxCallbacks - 1]
        fn = (what) ->
          what.should.equal 'sparta'
          inc()

        pubsub.subscribe event, fn

      pubsub.publish event, 'sparta'

  describe "#once", ->
    it "should throw when no event is defined", ->
      pubsub = new PubSub()
      (-> pubsub.once undefined).should.throw "No event defined"

    it "should throw when no callback is defined", ->
      pubsub = new PubSub()
      (-> pubsub.once 'event', undefined).should.throw "No callback defined"

    it "should register callback just once for that event", (done) ->
      pubsub = new PubSub()
      event  = 'once.event'
      calls  = 0
      fn = (test) ->
        test.should.be.equal 'test'
        calls += 1
        throw new Error "callback called multiple times" if calls isnt 1

      pubsub.once event, fn
      pubsub.publish event, 'test'
      pubsub.publish event, 'test'

      setTimeout (
        ->
        assert calls is 1
        done()
      ), 10

    it "should be able to remove callback", ->
      pubsub = new PubSub()
      event  = 'once.event'
      calls  = 0
      fn = ->

      pubsub.once event, fn
      pubsub.unsubscribe event, fn

      pubsub._pubsub[event].should.be.instanceOf(Array)
                           .and.be.empty

  describe "API must be chainable", ->
    it "publish should be chainable", ->
      pubsub = new PubSub()
      pubsub.publish('test', ->).should.equal pubsub


    it "unsubscribe should be chainable", ->
      pubsub = new PubSub()
      pubsub.unsubscribe('test', ->).should.equal pubsub


    it "trigger should be chainable", ->
      pubsub = new PubSub()
      pubsub.trigger('test', ->).should.equal pubsub


    it "once should be chainable", ->
      pubsub = new PubSub()
      pubsub.once('test', ->).should.equal pubsub
