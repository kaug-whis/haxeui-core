package haxe.ui.core;

import haxe.ui.Toolkit;
import haxe.ui.events.Events;
import haxe.ui.events.KeyboardEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.EventMap;
import haxe.ui.util.FunctionArray;

class ComponentEvents extends ComponentContainer {
    public function new() {
        super();
    }

    @:noCompletion private var _internalEvents:Events = null;
    @:noCompletion private var _internalEventsClass:Class<Events> = null;
    private function registerInternalEvents(eventsClass:Class<Events> = null, reregister:Bool = false) {
        if (_internalEvents == null && eventsClass != null) {
            _internalEvents = Type.createInstance(eventsClass, [this]);
            _internalEvents.register();
        } if (reregister == true && _internalEvents != null) {
            _internalEvents.register();
        }
    }
    private function unregisterInternalEvents() {
        if (_internalEvents == null) {
            return;
        }
        _internalEvents.unregister();
        _internalEvents = null;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    @:noCompletion private var __events:EventMap;

    /**
     Register a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function registerEvent<T:UIEvent>(type:String, listener:T->Void, priority:Int = 0) {
        if (cast(this, Component).hasClass(":mobile") && (type == MouseEvent.MOUSE_OVER || type == MouseEvent.MOUSE_OUT)) {
            return;
        }

        if (disabled == true && isInteractiveEvent(type) == true) {
            if (_disabledEvents == null) {
                _disabledEvents = new EventMap();
            }
            _disabledEvents.add(type, listener, priority);
            return;
        }

        if (__events == null) {
            __events = new EventMap();
        }
        if (__events.add(type, listener, priority) == true) {
            mapEvent(type, _onMappedEvent);
        }
    }

    /**
     Returns if this component has a certain event and listener
    **/
    @:dox(group = "Event related properties and methods")
    public function hasEvent<T:UIEvent>(type:String, listener:T->Void = null):Bool {
        if (__events == null) {
            return false;
        }
        return __events.contains(type, listener);
    }

    /**
     Unregister a listener for a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public function unregisterEvent<T:UIEvent>(type:String, listener:T->Void) {
        if (_disabledEvents != null && !_interactivityDisabled) {
            _disabledEvents.remove(type, listener);
        }

        if (__events != null) {
            if (__events.remove(type, listener) == true) {
                unmapEvent(type, _onMappedEvent);
            }
        }
    }

    /**
     Dispatch a certain `UIEvent`
    **/
    @:dox(group = "Event related properties and methods")
    public override function dispatch(event:UIEvent) {
        if (event != null) {
            if (__events != null) {
                __events.invoke(event.type, event, cast(this, Component));  // TODO: avoid cast
            }

            if (event.bubble == true && event.canceled == false && parentComponent != null) {
                parentComponent.dispatch(event);
            }
        }
    }

    private function dispatchRecursively(event:UIEvent) {
        dispatch(event);
        for (child in childComponents) {
            child.dispatchRecursively(event);
        }
    }

    private function dispatchRecursivelyWhen(event:UIEvent, condition:Component->Bool) {
        if (condition(cast this) == true) {
            dispatch(event);
        }
        for (child in childComponents) {
            if (condition(child) == true) {
                child.dispatchRecursivelyWhen(event, condition);
            }
        }
    }
    
    @:noCompletion 
    private function _onMappedEvent(event:UIEvent) {
        dispatch(event);
    }

    @:noCompletion private var _disabledEvents:EventMap;
    private static var INTERACTIVE_EVENTS:Array<String> = [
        MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_OUT, MouseEvent.MOUSE_DOWN,
        MouseEvent.MOUSE_UP, MouseEvent.MOUSE_WHEEL, MouseEvent.CLICK, MouseEvent.DBL_CLICK, KeyboardEvent.KEY_DOWN,
        KeyboardEvent.KEY_UP
    ];

    private function isInteractiveEvent(type:String):Bool {
        return INTERACTIVE_EVENTS.indexOf(type) != -1;
    }

    private function disableInteractiveEvents(disable:Bool) {
        if (disable == true) {
            if (__events != null) {
                for (eventType in __events.keys()) {
                    if (!isInteractiveEvent(eventType)) {
                        continue;
                    }
                    var listeners:FunctionArray<UIEvent->Void> = __events.listeners(eventType);
                    if (listeners != null) {
                        for (listener in listeners.copy()) {
                            if (_disabledEvents == null) {
                                _disabledEvents = new EventMap();
                            }
                            _disabledEvents.add(eventType, listener);
                            unregisterEvent(eventType, listener);
                        }
                    }
                }
            }
        } else {
            if (_disabledEvents != null) {
                for (eventType in _disabledEvents.keys()) {
                    var listeners:FunctionArray<UIEvent->Void> = _disabledEvents.listeners(eventType);
                    if (listeners != null) {
                        for (listener in listeners.copy()) {
                            registerEvent(eventType, listener);
                        }
                    }
                }
                _disabledEvents = null;
            }
        }
    }
    
    @:noCompletion private var _interactivityDisabled:Bool = false;
    @:noCompletion private var _interactivityDisabledCounter:Int = 0;
    #if haxeui_html5
    private var _lastCursor:String = null;
    #end
    private function disableInteractivity(disable:Bool, recursive:Bool = true, updateStyle:Bool = false, force:Bool = false) { // You might want to disable interactivity but NOT actually disable visually
        if (force == true) {
            _interactivityDisabledCounter = 0;
        }
        if (disable == true) {
            _interactivityDisabledCounter++;
        } else {
            _interactivityDisabledCounter--;
        }

        if (_interactivityDisabledCounter > 0 && _interactivityDisabled == false) {
            _interactivityDisabled = true;
            if (updateStyle == true) {
                cast(this, Component).swapClass(":disabled", ":hover");
            }
            handleDisabled(true);
            disableInteractiveEvents(true);
            dispatch(new UIEvent(UIEvent.DISABLED));
            #if haxeui_html5
            _lastCursor = cast(this, Component).element.style.cursor;
            cast(this, Component).element.style.removeProperty("cursor");
            #end
        } else if (_interactivityDisabledCounter < 1 && _interactivityDisabled == true) {
            _interactivityDisabled = false;
            if (updateStyle == true) {
                cast(this, Component).removeClass(":disabled");
            }
            handleDisabled(false);
            disableInteractiveEvents(false);
            dispatch(new UIEvent(UIEvent.ENABLED));
            #if haxeui_html5
            if (_lastCursor != null) {
                cast(this, Component).element.style.cursor = _lastCursor;
            }
            #end
        }

        if (recursive == true) {
            for (child in childComponents) {
                child.disableInteractivity(disable, recursive, updateStyle);
            }
        }
    }

    private function unregisterEvents() {
        if (__events != null) {
            var copy:Array<String> = [];
            for (eventType in __events.keys()) {
                copy.push(eventType);
            }
            for (eventType in copy) {
                var listeners = __events.listeners(eventType);
                if (listeners != null) {
                    for (listener in listeners) {
                        if (listener != null) {
                            if (__events.remove(eventType, listener) == true) {
                                unmapEvent(eventType, _onMappedEvent);
                            }
                        }
                    }
                }
            }
        }
    }

    @:noCompletion private var _pausedEvents:Map<String, Array<UIEvent->Void>> = null;
    public function pauseEvent(type:String, recursive:Bool = false) {
        if (__events == null || __events.contains(type) == false) {
            return;
        }
        
        if (_pausedEvents == null) {
            _pausedEvents = new Map<String, Array<UIEvent->Void>>();
        }
        
        var pausedList = _pausedEvents.get(type);
        if (pausedList == null) {
            pausedList = new Array<UIEvent->Void>();
            _pausedEvents.set(type, pausedList);
        }
        
        var listeners = __events.listeners(type).copy();
        for (l in listeners) {
            pausedList.push(l);
            unregisterEvent(type, l);
        }
        
        if (recursive == true) {
            for (c in childComponents) {
                c.pauseEvent(type, recursive);
            }
        }
    }
    
    public function resumeEvent(type:String, recursive:Bool = false) {
        if (__events == null) {
            return;
        }
        
        if (_pausedEvents == null) {
            return;
        }
        
        if (_pausedEvents.exists(type) == false) {
            return;
        }
        
        Toolkit.callLater(function() {
            var pausedList = _pausedEvents.get(type);
            for (l in pausedList) {
                registerEvent(type, l);
            }
            _pausedEvents.remove(type);
        });
        
        if (recursive == true) {
            for (c in childComponents) {
                c.resumeEvent(type, recursive);
            }
        }
    }
    
    private function mapEvent(type:String, listener:UIEvent->Void) {
    }

    private function unmapEvent(type:String, listener:UIEvent->Void) {

    }
}