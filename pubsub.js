// Generated by CoffeeScript 1.4.0
(function() {
  var PubSub,
    __slice = [].slice;

  PubSub = (function() {

    function PubSub() {
      this._pubsub = {};
    }

    PubSub.prototype._callback = function(callback, context) {
      if (context == null) {
        context = this;
      }
      return {
        wrapped: (function() {
          return callback.apply(context, arguments);
        }),
        original: callback
      };
    };

    PubSub.prototype.subscribe = function(event, callback, context) {
      var _base;
      if (typeof callback !== 'function') {
        throw new Error("No callback defined");
      }
      if (typeof event === 'undefined') {
        throw new Error("No event defined");
      }
      if (typeof context !== 'undefined') {
        callback = this._callback(callback, context);
      }
      (_base = this._pubsub)[event] || (_base[event] = []);
      return this._pubsub[event].push(callback);
    };

    PubSub.prototype.unsubscribe = function(event, callback) {
      var callb, callbacks, i, _i, _ref, _results;
      if (typeof event === 'undefined' && typeof callback === 'undefined') {
        this._pubsub = {};
      }
      if (typeof callback === 'undefined') {
        delete this._pubsub[event];
      }
      callbacks = this._pubsub[event] || [];
      _results = [];
      for (i = _i = _ref = callbacks.length - 1; _ref <= -1 ? _i < -1 : _i > -1; i = _ref <= -1 ? ++_i : --_i) {
        callb = callbacks[i];
        if (typeof callb === 'object') {
          callb = callb.original;
        }
        if (callb === callback) {
          _results.push(callbacks.splice(i, 1));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    PubSub.prototype.publish = function() {
      var args, callback, callbacks, event, _i, _len, _results;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (typeof event === 'undefined') {
        throw new Error("No event defined");
      }
      callbacks = this._pubsub[event] || [];
      _results = [];
      for (_i = 0, _len = callbacks.length; _i < _len; _i++) {
        callback = callbacks[_i];
        if (typeof callback === 'object') {
          callback = callback.wrapped;
        }
        _results.push(callback.apply(this, args));
      }
      return _results;
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
  }

}).call(this);
