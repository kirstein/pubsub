# # Wrap the function
# do (global = this) ->
#   "use strict"

class PubSub

  constructor: ->
    # Data for the current pubsub
    @_pubsub = {}

  # Proxy callback, will make sure that the context stays the same
  _callback   : (callback, context = @) ->
    # Save the object, keep the original callback
    return  wrapped  : (-> callback.apply context, arguments)
           ,original : callback

  # Subscribes to event
  # Mandatory parameters are event and callback
  # If context is defined then it will proxy the callback through that context
  subscribe   : (event, callback, context) ->
    throw new Error "No callback defined" if typeof callback isnt 'function'
    throw new Error "No event defined"    if typeof event    is   'undefined'

    # Proxy the callback if context is set
    callback = @_callback callback, context if typeof context isnt 'undefined'

    @_pubsub[event] or= []
    @_pubsub[event].push callback

  # Unsubscribes callback from PubSub
  # If no arguments are given will clear the state of pubsub
  # If no callback is defined then it will clear all the callbacks for that event
  unsubscribe : (event, callback) ->
    # Clear the state if both event and callback is undefined
    @_pubsub = {} if typeof event is 'undefined' and typeof callback is 'undefined'

    # Delete all callbacks of that event IF no callback is defined
    delete @_pubsub[event] if typeof callback is 'undefined'

    # Reverse loop through callbacks list
    callbacks = @_pubsub[event] or []
    for i in [callbacks.length-1...-1]
      callb = callbacks[i]

      # If the callback is an object
      # extract the original callback out of it
      callb = callb.original if typeof callb is 'object'

      # If the callback is the same, remove it
      callbacks.splice i, 1 if callb is callback


  # Publish the event
  # Event will be published to all callbacks that have subscribed.
  # All arguments shall be passed
  publish : (event, args...) ->
    throw new Error "No event defined" if typeof event is 'undefined'

    # Loop through all callbacks and trigger with arguments
    callbacks = @_pubsub[event] or []
    for callback in callbacks

      # Check if callback is an object
      # If its a object extract wrapped callback from it
      callback = callback.wrapped if typeof callback is 'object'
      callback.apply @, args

  # Create links for easier access
  # Link subscribe to on
  on       : @::subscribe
  # Link unsubscribe to off
  off      : @::unsubscribe
  # Link trigger to publish
  trigger  : @::publish

# Expose pubsub
# Check for variety loaders
if typeof define is 'function' and typeof define.amd is 'object' and define.amd
  # If AMD loaders are defined then expose the pubsub via define
  define -> return PubSub

# Check for `exports` after `define` in case a build optimizer adds an `exports` object
# in Node.js or RingoJS v0.8.0+
else if typeof module is 'object' and module and module.exports
  module.exports = PubSub
