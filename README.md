# PubSub

Publish-Subscribe pattern implementation in CoffeeScript

## API

  * subscribe(event, callback, [context])  
    Subscribe a function to given event.  
    Callback will be registered to event and will be called when the event is triggered.  
    If context is set then callback will be called using that context.

  * unsubscribe([event], [callback])
  * trigger(event, [args...])
  * once(event, callback, [context])
  
  