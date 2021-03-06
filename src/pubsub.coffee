###
  @author Mikk Kirstein http://www.github.com/kirstein

  An implementation of Publish/Subscribe pattern.
  Simple pubsub that can be used to spice up your application.
###
class PubSub

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
    If no event is defined and callback OR context is then
       it will search through all events and remove the given callback that matches the callback or context

    @param {String}   event    Name of the event
    @param {Function} callback Function to be removed
    @param {Object|Function} context context to be removed
  ###
  unsubscribe : (event, callback, context) ->
    # Return if no events have been registered
    if not @_pubsub
      return @

    if not event?
      # Clear the state if both event and callback is undefined
      if not callback? and not context?
        delete @_pubsub
        return @

      # If the event is not defined and either callback or context is
      # Then recursive loop all events and search for the callbacks to remove
      else
        @unsubscribe key, callback, context for own key, val of @_pubsub when key?
        return @

    # If the event is defined and callback and context are not
    # Then remove the event and return
    else if not callback? and not context?
      delete @_pubsub[event]
      return @

    # Reverse loop through callbacks list
    # Looping in reverse because then we can remove necessary events on the fly
    callbacks = @_pubsub[event] or []
    for i in [callbacks.length-1...-1]

      # Get the callback
      callb = callbacks[i].callback
      cntxt = callbacks[i].context

      # Check if we are dealing with a wrapper
      # If thats the case lets extract the original callback out of it
      callb = callb._original or callb

      # Remove the callback from list if:
      #   !context and callback == callback
      #   !callback and (context === context)
      #   callback  and  context === context
      if (callback? and context? and cntxt is context and callb is callback) or
         (not context?           and callb is callback) or
         (not callback?          and cntxt is context)
          callbacks.splice i, 1

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
    throw new Error "No event defined" if not event?

    # No pubsub is defined
    return @ if not @_pubsub

    # Loop through all callbacks and trigger with arguments
    # Using reverse loop in case some event gets unsubscribed at the same time
    callbacks = @_pubsub[event] or []
    for i in [callbacks.length-1...-1]
      callb = callbacks[i]

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
    throw new Error "No event defined"    if not event?
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
