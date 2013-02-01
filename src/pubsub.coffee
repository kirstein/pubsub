###
  @author Mikk Kirstein http://www.github.com/kirstein

  An implementation of Publish/Subscribe pattern.
  Simple pubsub that can be used to spice up your application.
###
class PubSub

  constructor: ->

  ###
    Subscribes a callback to a event.
    Callback will be called when the event is triggered using the #trigger method.
    When context is no defined the context will be set for this.

    @param {String}          event    Name of the event that callback will be registered to listen
    @param {Function}        callback Function that will be triggered on given event
    @param {Object|Function} context  Context that event will be triggered through when calling
  ###
  subscribe   : (event, callback, context) ->
    throw new Error "No event defined"    if not event?
    throw new Error "No callback defined" if typeof callback isnt 'function'

    # Setup a pubsub if its not initiated yet
    @_pubsub or= {}

    # Stored callback object
    callb = callback : callback
            ,context : context or @

    @_pubsub[event] or= []
    @_pubsub[event].push callb

    return @

  ###
    Unsubscribes callback from PubSub
    If no arguments are given will clear the state of pubsub (remove all events and their listeners).
    If no callback is defined then it will clear all the callbacks for that event.
    If no event is defined and callback is then it will search through all events and remove the given callback

    @param {String}   event    Name of the event
    @param {Function} callback Function to be removed
  ###
  unsubscribe : (event, callback) ->
    # Clear the state if both event and callback is undefined
    if not event? and not callback?
      delete @_pubsub
      return @

    # Return if no events have been registered
    if not @_pubsub
      return @

    # Delete all callbacks of that event IF no callback is defined
    # Deletes references to those callbacks
    delete @_pubsub[event] if not callback?

    # If the event is not defined and the callback is
    # then remove events recursively
    if not event? and callback
      # Trigger recursively loop
      @unsubscribe key, callback for own key, val of @_pubsub
      return @

    # Reverse loop through callbacks list
    callbacks = @_pubsub[event] or []
    for i in [callbacks.length-1...-1]

      # Get the callback
      callb = callbacks[i].callback

      # Check if we are dealing with a wrapper
      # If thats the case lets extract the original callback out of it
      if callb._original then callb = callb._original

      # If the callback is the same, remove it
      callbacks.splice i, 1 if callb is callback

    return @

  ###
    Publishes the event to all its listeners.
    Event will be published to all callbacks that have subscribed.
    All arguments shall be passed on to callback.

    Triggered callbacks will be referenced to either the context that was given
    when subscribing the event or this (pubsub)

    @param {String} event     Event to be triggered
    @param {*}      arguments Arguments to be passed to function on calling
  ###
  publish : (event, args...) ->
    throw new Error "No event defined" if typeof event is 'undefined'

    # No pubsub is defined
    return @ if not @_pubsub

    # Loop through all callbacks and trigger with arguments
    callbacks = @_pubsub[event] or []
    for callb in callbacks

      # Check if callback is an object
      # If its a object extract wrapped callback from it
      callback = callb.callback
      callback.apply callb.context, args

    return @

  ###
    Subscribe to event only for one callback.
    After the first callback is triggered the callback will be removed from callbacks list.

    @param {String}          event    Name of the event that callback will be registered to listen
    @param {Function}        callback Function that will be triggered on given event
    @param {Object|Function} context  Context that event will be triggered through when calling
  ###
  once : (event, callback, context) ->
    throw new Error "No event defined"    if typeof event    is   'undefined'
    throw new Error "No callback defined" if typeof callback isnt 'function'

    # Wrap the callback into closure.
    # New function will remove the wrapper from list if its called
    wrapped = ->
      # Delete the reference to original callback
      # and unsubscribe the wrapper function
      delete wrapped._original
      @unsubscribe event, wrapped

      # Trigger the actual callback
      callback.apply context, arguments

    # Attach the original callback to wrapper
    # Needed for unsubscribing
    wrapped._original = callback

    # Subscribe the wrapped function
    return @subscribe event, wrapped

  # Create links for easier access
  # Link subscribe -> on
  on       : @::subscribe
  # Link unsubscribe -> off
  off      : @::unsubscribe
  # Link trigger -> publish
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

# Add it to global
else
  @.PubSub = PubSub
