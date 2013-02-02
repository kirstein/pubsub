# PubSub

Publish-Subscribe pattern implementation in CoffeeScript

## API

  * [subscribe(event, callback, [context])](#subscribe)
  * [unsubscribe([event], [callback])](#unsubscribe)
  * [publish(event, [args...])](#publish)
  * [once(event, callback, [context])](#once)
  * [on(event, callback, [context])](#subscribe)
  * [off([event], [callback])](#off)
  * [trigger(event, [args...])](#publish)
  
## Detailed API

### #subscribe
> For easier access the method `subscribe` can be called also with name `on`

Subscribes a `callback` to answer if a describe event will be triggered `event`.  
Parameters (required parameters in __bold__, optional parameters in _italic_):

  1. __event__    {String} Name of the event that the given `callback` will register to.
  2. __callback__ {Function} Callback that will be called if a describe `event` will be published. Callback will be triggered with context of pubsub unless the user has specifically defined a `context` on publishing the `callback`
  3. _context_    {Object|Function} If set then the defined `callback` will be called with the defined `context`

Usage:

    var pubsub = new PubSub();
    
    // Pubsub will wait until the event 'render:done' is published.  
    // After the event is published it will call the callback function with given arguments  
    // and will set 'this' as context of the callback.
    pubsub.subscribe('render:done', function(view) {
      // Logic here
    }, this);
    
### #unsubscribe
> For easier access the method `unsubscribe` can be called also with name `off`

Unsubscribes (remove) a previously subscribed event or callback from pubsub.  
Has four (4) different use cases:  

1. If __no__ event AND callback __is__ given then it will unsubscribe (remove) given callback from all registered events.  
2. If __no__ event AND __no__ callback is given then it will clear unsubscribe all subscribed callbacks (clear the pubsub)  
3. If event __is__ given AND callback __is__ given then it will just remove the given callback from callbacks list for that event.  
4. If event __is__ given AND __no__ callback is given then it will unsubscribe all callbacks that are linked to that event name.

Parameters (required parameters in __bold__, optional parameters in _italic_):

  1. _event_    {String} Name of the event to be removed.
  2. _callback_ {Function} Callback to be removed.

Usage:

When only callback is given:

    var callback = function() {};

    // Will search through the whole pubsub and unsubscribe all callbacks that match the given one
    pubsub.unsubscribe(null, callback);


When no event and no callback is given:

    // Will unsubscribe all callbacks from pubsub (clears the state)
    pubsub.unsubscribe();

When event and callback is given:

    var callback = function() {};

    // Will unsubscribe the given function from the given event.
    pubsub.unsubscribe('event:name', callback);
    
### #publish
> For easier access the method `publish` can be called also with name `trigger`

Triggers previously subscribed event with given arguments.

Parameters (required parameters in __bold__, optional parameters in _italic_):

  1. _event_    {String} Name of the event to be triggered.
  2. _args_     {*} Arguments to be passed.

Usage:

    var pubsub = new PubSub(),
        fn     = function(one, two) { 
                    if (one !== 'hello' && two !== 'world') {
                      throw new Error("This sucks");
                    }
                 };

    // Register the callback to be called if 'event' will be published
    pubsub.subscribe('event', fn);

    // Trigger the event with two arguments 'hello' and 'world'
    pubsub.publish('event', 'hello', 'world');
    
### #once

[Subscribe](#subscribe) the event for only callback.

Usage:

    var pubsub = new PubSub(),
        fn     = function(one, two) { 
                    if (one !== 'hello' && two !== 'world') {
                      throw new Error("This sucks");
                    }
                 };

    // Register the callback to be called if 'event' will be published
    // The callback will be called only once
    pubsub.once('event', fn);

    // Trigger the event with two arguments 'hello' and 'world'
    pubsub.publish('event', 'hello', 'world');
    
    // Triggering the event the second time wont produce any results
    pubsub.publish('event');