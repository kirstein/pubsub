// Generated by CoffeeScript 1.4.0

/*
  @author Mikk Kirstein http://www.github.com/kirstein

  An implementation of Publish/Subscribe pattern.
  Simple pubsub that can be used to spice up your application.
*/


(function() {
  var PubSub,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  PubSub = (function() {

    function PubSub() {}

    /*
        Subscribes a callback to a event.
        Callback will be called when the event is triggered using the #trigger method.
        When context is no defined the context will be set for this.
    
        @param {String}          event    Name of the event that callback will be registered to listen
        @param {Function}        callback Function that will be triggered on given event
        @param {Object|Function} context  Context that event will be triggered through when calling
    */


    PubSub.prototype.subscribe = function(event, callback, context) {
      var callb, _base;
      if (!(event != null)) {
        throw new Error("No event defined");
      }
      if (typeof callback !== 'function') {
        throw new Error("No callback defined");
      }
      this._pubsub || (this._pubsub = {});
      callb = {
        callback: callback,
        context: context || this
      };
      (_base = this._pubsub)[event] || (_base[event] = []);
      this._pubsub[event].push(callb);
      return this;
    };

    /*
        Unsubscribes callback from PubSub
        If no arguments are given will clear the state of pubsub (remove all events and their listeners).
        If no callback is defined then it will clear all the callbacks for that event.
        If no event is defined and callback is then it will search through all events and remove the given callback
    
        @param {String}   event    Name of the event
        @param {Function} callback Function to be removed
    */


    PubSub.prototype.unsubscribe = function(event, callback) {
      var callb, callbacks, i, key, val, _i, _ref, _ref1;
      if (!(event != null) && !(callback != null)) {
        delete this._pubsub;
        return this;
      }
      if (!this._pubsub) {
        return this;
      }
      if (!(callback != null)) {
        delete this._pubsub[event];
      }
      if (!(event != null) && callback) {
        _ref = this._pubsub;
        for (key in _ref) {
          if (!__hasProp.call(_ref, key)) continue;
          val = _ref[key];
          if (key != null) {
            this.unsubscribe(key, callback);
          }
        }
        return this;
      }
      callbacks = this._pubsub[event] || [];
      for (i = _i = _ref1 = callbacks.length - 1; _ref1 <= -1 ? _i < -1 : _i > -1; i = _ref1 <= -1 ? ++_i : --_i) {
        callb = callbacks[i].callback;
        if (callb._original) {
          callb = callb._original;
        }
        if (callb === callback) {
          callbacks.splice(i, 1);
        }
      }
      return this;
    };

    /*
        Publishes the event to all its listeners.
        Event will be published to all callbacks that have subscribed.
        All arguments shall be passed on to callback.
    
        Triggered callbacks will be referenced to either the context that was given
        when subscribing the event or this (pubsub)
    
        @param {String} event     Event to be triggered
        @param {*}      arguments Arguments to be passed to function on calling
    */


    PubSub.prototype.publish = function() {
      var args, callb, callback, callbacks, event, _i, _len;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (!(event != null)) {
        throw new Error("No event defined");
      }
      if (!this._pubsub) {
        return this;
      }
      callbacks = this._pubsub[event] || [];
      for (_i = 0, _len = callbacks.length; _i < _len; _i++) {
        callb = callbacks[_i];
        callback = callb.callback;
        callback.apply(callb.context, args);
      }
      return this;
    };

    /*
        Subscribe to event only for one callback.
        After the first callback is triggered the callback will be removed from callbacks list.
    
        @param {String}          event    Name of the event that callback will be registered to listen
        @param {Function}        callback Function that will be triggered on given event
        @param {Object|Function} context  Context that event will be triggered through when calling
    */


    PubSub.prototype.once = function(event, callback, context) {
      var wrapped;
      if (!(event != null)) {
        throw new Error("No event defined");
      }
      if (typeof callback !== 'function') {
        throw new Error("No callback defined");
      }
      wrapped = function() {
        delete wrapped._original;
        this.unsubscribe(event, wrapped);
        return callback.apply(context, arguments);
      };
      wrapped._original = callback;
      return this.subscribe(event, wrapped);
    };

    PubSub.prototype.on = PubSub.prototype.subscribe;

    PubSub.prototype.off = PubSub.prototype.unsubscribe;

    PubSub.prototype.trigger = PubSub.prototype.publish;

    return PubSub;

  })();

  if (typeof define === 'function' && typeof define.amd === 'object' && define.amd) {
    define(function() {
      return PubSub;
    });
  } else if (typeof module === 'object' && module && module.exports) {
    module.exports = PubSub;
  } else {
    this.PubSub = PubSub;
  }

}).call(this);
