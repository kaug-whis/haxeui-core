package haxe.ui.containers.windows;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.components.Label;
import haxe.ui.components.Image;
import haxe.ui.geom.Point;
import haxe.ui.core.Screen;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Slice9;
import haxe.ui.events.MouseEvent;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.behaviours.DataBehaviour;

@:xml('
    <vbox style="spacing:0;">
    </vbox>
')
@:composite(Builder)
class Window extends VBox {

    public var windowManager:WindowManager;

    @:behaviour(Minimizable, true) public var minimizable:Bool;
    @:behaviour(Collapsable, true) public var collapsable:Bool;
    @:behaviour(Maximizable, true) public var maximizable:Bool;
    @:behaviour(Closable, true) public var closable:Bool;

    @:behaviour(Maximized) public var maximized:Bool;
    @:behaviour(Minimized) public var minimized:Bool;

    public var title(get, set):String;
    private function get_title():String {
        var label = findComponent("windowTitleLabel", Label);
        if (label != null) {
            return label.text;
        }
        return null;
    }
    private function set_title(value:String):String {
        var label = findComponent("windowTitleLabel", Label);
        if (label != null) {
            label.text = value;
        }
        return value;
    }

    #if (haxeui_openfl || haxeui_nme || haxeui_flixel)
    public override function set_width(value:Float):Float {
    #else
    public override function set_width(value:Null<Float>):Null<Float> {
    #end    
        var wrapper = findComponent("windowWrapper", VBox);
        if (wrapper != null) {
            wrapper.percentWidth = 100;
        }
        var content = findComponent("windowContent", VBox);
        if (content != null) {
            content.percentWidth = 100;
        }
        return super.set_width(value);
    }

    #if (haxeui_openfl || haxeui_nme || haxeui_flixel)
    public override function set_height(value:Float):Float {
    #else
    public override function set_height(value:Null<Float>):Null<Float> {
    #end    
        var wrapper = findComponent("windowWrapper", VBox);
        if (wrapper != null) {
            wrapper.percentHeight = 100;
        }
        var content = findComponent("windowContent", VBox);
        if (content != null) {
            content.percentHeight = 100;
        }
        return super.set_height(value);
    }

    public function messageBox(message:String, title:String = null, type:MessageBoxType = null, modal:Bool = true, callback:DialogButton->Void = null):Dialog {
        if (type == null) {
            type = MessageBoxType.TYPE_INFO;
        } else if (type == "info") {
            type = MessageBoxType.TYPE_INFO;
        } else if (type == "question") {
            type = MessageBoxType.TYPE_QUESTION;
        } else if (type == "warning") {
            type = MessageBoxType.TYPE_WARNING;
        } else if (type == "error") {
            type = MessageBoxType.TYPE_ERROR;
        } else if (type == "yesno") {
            type = MessageBoxType.TYPE_YESNO;
        }

        var messageBox = new MessageBox();
        #if hxwidgets
        messageBox.dialogParent = findComponent("windowContent", VBox);
        #end
        messageBox.type = type;
        messageBox.message = message;
        messageBox.modal = modal;
        if (title != null) {
            messageBox.title = title;
        }
        messageBox.show();
        if (callback != null) {
            messageBox.registerEvent(DialogEvent.DIALOG_CLOSED, function(e:DialogEvent) {
                callback(e.button);
            });
        }

        return messageBox;
    }
}

@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.windows.Window.Builder)
private class Closable extends DataBehaviour {
    private override function validateData() {
        var title = cast(_component._compositeBuilder, Builder).title;
        if (title != null) {
            var existing = title.findComponent("windowCloseButton", Image);
            if (_value == true && existing == null) {
                existing = new Image();
                existing.id = "windowCloseButton";
                title.addComponent(existing);
                existing.registerEvent(MouseEvent.MOUSE_DOWN, function(event:MouseEvent) {
                    event.cancel();
                    var window = cast(_component, Window);
                    existing.removeClass(":hover");
                    window.windowManager.closeWindow(window); 
                });
            } else if (_value == false && existing != null) {
                title.removeComponent(existing);
            }
        }
    }
}

@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.windows.Window.Builder)
private class Collapsable extends DataBehaviour {
    private override function validateData() {
        var title = cast(_component._compositeBuilder, Builder).title;
        if (title != null) {
            var existing = title.findComponent("windowCollapseButton", Image);
            if (_value == true && existing == null) {
                existing = new Image();
                existing.id = "windowCollapseButton";
                title.addComponent(existing);
            } else if (_value == false && existing != null) {
                title.removeComponent(existing);
            }
        }
    }
}

@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.windows.Window.Builder)
private class Minimizable extends DataBehaviour {
    private override function validateData() {
        var title = cast(_component._compositeBuilder, Builder).title;
        if (title != null) {
            var existing = title.findComponent("windowMinimizeButton", Image);
            if (_value == true && existing == null) {
                existing = new Image();
                existing.id = "windowMinimizeButton";
                title.addComponent(existing);
                existing.registerEvent(MouseEvent.MOUSE_DOWN, function(event:MouseEvent) {
                    event.cancel();
                    var window = cast(_component, Window);
                    existing.removeClass(":hover");
                    window.windowManager.minimizeWindow(window);
                });
            } else if (_value == false && existing != null) {
                title.removeComponent(existing);
            }
        }
    }
}

@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.windows.Window.Builder)
private class Maximizable extends DataBehaviour {
    private override function validateData() {
        var title = cast(_component._compositeBuilder, Builder).title;
        if (title != null) {
            var existing = title.findComponent("windowMaximizeButton", Image);
            if (_value == true && existing == null) {
                existing = new Image();
                existing.id = "windowMaximizeButton";
                title.addComponent(existing);
                existing.registerEvent(MouseEvent.MOUSE_DOWN, function(_) {
                    var window = cast(_component, Window);
                    existing.removeClass(":hover");
                    if (window.maximized) {
                        window.windowManager.restoreWindow(window); 
                    } else {
                        window.windowManager.maximizeWindow(window);
                    }
                });
            } else if (_value == false && existing != null) {
                title.removeComponent(existing);
            }
        }
    }
}

@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.windows.Window.Builder)
private class Maximized extends DataBehaviour {
    private override function validateData() {
        var title = cast(_component._compositeBuilder, Builder).title;
        if (title != null) {
            var existing = title.findComponent("windowMaximizeButton", Image);
            if (existing != null) {
                if (_value == true) {
                    _component.dragInitiator = null;
                    existing.addClass("restore");
                } else {
                    _component.dragInitiator = title;
                    existing.removeClass("restore");
                }
            }

            var existing = title.findComponent("windowCollapseButton", Image);
            if (existing != null) {
                if (_value == true) {
                    existing.hide();
                } else {
                    existing.show();
                }
            }
        }
    }
}

@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.windows.Window.Builder)
private class Minimized extends DataBehaviour {
    private override function validateData() {
    }
}

@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _window:Window;
    private var _windowWrapper:VBox;
    public var title:WindowTitle = null;
    private var _content:VBox;
    private var _footer:WindowFooter;

    public function new(window:Window) {
        super(window);
        _window = window;
    }

    public override function create() {
        super.create();
        _window.removeClass("window");
        _window.addClass("window-container");

        _windowWrapper = new VBox();
        _windowWrapper.addClass("window");
        _windowWrapper.addClass("window-wrapper");
        _windowWrapper.id = "windowWrapper";
        _window.addComponent(_windowWrapper);

        if (title == null) {
            title = new WindowTitle();
            title.registerEvent(MouseEvent.DBL_CLICK, function(_) {
                if (_window.maximized) {
                    _window.windowManager.restoreWindow(_window); 
                } else {
                    _window.windowManager.maximizeWindow(_window);
                }
            });
            _window.addComponent(title);
            _window.dragInitiator = title;
        }

        _content = new VBox();
        _content.addClass("window-content");
        _content.id = "windowContent";
        _window.addComponent(_content);

        _window.registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        _window.registerEvent(MouseEvent.MOUSE_MOVE, onMouseMove);
        _window.registerEvent(MouseEvent.MOUSE_OUT, onMouseOut);
    }

    private var _resizeN = false;
    private var _resizeE = false;
    private var _resizeS = false;
    private var _resizeW = false;
    private var _tolerance:Float = 10;
    private var _downPoint:Point = new Point();
    private function onMouseDown(e:MouseEvent) {
        _downPoint.x = e.screenX;
        _downPoint.y = e.screenY;
        _window.windowManager.bringToFront(_window);

        if (_resizeN || _resizeE || _resizeS || _resizeW) {
            e.cancel();
            for (w in _window.windowManager.windows) {
                w.disableInteractivity(true);
            }
            _window.unregisterEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
            _window.unregisterEvent(MouseEvent.MOUSE_MOVE, onMouseMove);
            _window.unregisterEvent(MouseEvent.MOUSE_OUT, onMouseOut);

            Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
            Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
        }
    }

    private function onScreenMouseMove(e:MouseEvent) {
        var sx = e.screenX;
        var sy = e.screenY;

        var updatePoint = true;
        if (_resizeE) {
            var newCX = _window.width + sx - _downPoint.x;
            if (newCX < 180) { // TODO
                newCX = 180;
                updatePoint = false;
            }
            _window.width = newCX;
        } else if (_resizeW) {
            _window.left += sx - _downPoint.x;
            _window.width -= sx - _downPoint.x;
        }

        if (_resizeS) {
            _window.height += sy - _downPoint.y;
        } else if (_resizeN) {
            _window.top += sy - _downPoint.y;
            _window.height -= sy - _downPoint.y;
        }

        if (updatePoint) {
            _downPoint.x = e.screenX;
            _downPoint.y = e.screenY;
        }
    }

    private function onScreenMouseUp(e:MouseEvent) {
        for (w in _window.windowManager.windows) {
            w.disableInteractivity(false);
        }

        _resizeN = false;
        _resizeE = false;
        _resizeS = false;
        _resizeW = false;
        _windowWrapper.removeClasses(["size-nw", "size-n", "size-ne", "size-w", "size-e", "size-sw", "size-s", "size-se"]);

        _window.registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
        _window.registerEvent(MouseEvent.MOUSE_MOVE, onMouseMove);
        _window.registerEvent(MouseEvent.MOUSE_OUT, onMouseOut);

        Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onScreenMouseMove);
        Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onScreenMouseUp);
    }

    private function onMouseOut(e:MouseEvent) {
        _resizeN = false;
        _resizeE = false;
        _resizeS = false;
        _resizeW = false;
        _windowWrapper.removeClasses(["size-nw", "size-n", "size-ne", "size-w", "size-e", "size-sw", "size-s", "size-se"]);

        #if haxeui_html5
            js.Browser.document.body.style.removeProperty("cursor");
        #end
    }

    private function onMouseMove(e:MouseEvent) {
        if (_window.maximized) {
            return;
        }

        _resizeN = false;
        _resizeE = false;
        _resizeS = false;
        _resizeW = false;
        _windowWrapper.removeClasses(["size-nw", "size-n", "size-ne", "size-w", "size-e", "size-sw", "size-s", "size-se"]);

        var x = e.localX;
        var y = e.localY;
        var w = _window.width;
        var h = _window.height;

        var classToAdd = null;
        var cursor = null;
        var rects = Slice9.buildSrcRects(w, h, new Rectangle(_tolerance, _tolerance, w - _tolerance * 2, h - _tolerance * 2));
        if (rects[0].containsPoint(x, y)) { // top left
            _resizeN = true;
            _resizeW = true;
            classToAdd = "size-nw";
            cursor = "nwse-resize";
        } else if (rects[1].containsPoint(x, y)) { // top middle
            _resizeN = true;
            classToAdd = "size-n";
            cursor = "ns-resize";
        } else if (rects[2].containsPoint(x, y)) { // top right
            _resizeN = true;
            _resizeE = true;
            classToAdd = "size-ne";
            cursor = "nesw-resize";
        } else if (rects[3].containsPoint(x, y)) { // left middle
            _resizeW = true;
            classToAdd = "size-w";
            cursor = "ew-resize";
        } else if (rects[5].containsPoint(x, y)) { // right middle
            _resizeE = true;
            classToAdd = "size-e";
            cursor = "ew-resize";
        } else if (rects[6].containsPoint(x, y)) { // bottom left
            _resizeS = true;
            _resizeW = true;
            classToAdd = "size-sw";
            cursor = "nesw-resize";
        } else if (rects[7].containsPoint(x, y)) { // bottom middle
            _resizeS = true;
            classToAdd = "size-s";
            cursor = "ns-resize";
        } else if (rects[8].containsPoint(x, y)) { // bottom right
            _resizeS = true;
            _resizeE = true;
            classToAdd = "size-se";
            cursor = "nwse-resize";
        }

        if (classToAdd != null) {
            _windowWrapper.addClass(classToAdd);
        }

        #if haxeui_html5
            if (cursor != null) {
                js.Browser.document.body.style.cursor = cursor;
            } else {
                js.Browser.document.body.style.removeProperty("cursor");
            }
        #else
            _window.customStyle.cursor = cursor;
            title.customStyle.cursor = cursor;

            _window.invalidateComponentStyle();
            title.invalidateComponentStyle();
        #end

    }

    public override function addComponent(child:Component):Component {
        if ((child is WindowTitle)) {
            if (title != child) {
                if (title != null) {
                    _windowWrapper.removeComponent(title);
                    _window.dragInitiator = null;
                }
                title = cast child;
                _window.dragInitiator = title;
                title.registerEvent(MouseEvent.DBL_CLICK, function(_) {
                    if (_window.maximized) {
                        _window.windowManager.restoreWindow(_window); 
                    } else {
                        _window.windowManager.maximizeWindow(_window);
                    }
                });
                return _windowWrapper.addComponentAt(child, 0);
            }
        }
        if ((child is WindowFooter)) {
            _footer = cast child;
            return _windowWrapper.addComponent(child);
        }
        if (child == title || child == _content || child == _footer) {
            return _windowWrapper.addComponent(child);
        }
        if (child != _windowWrapper) {
            return _content.addComponent(child);
        }
        return super.addComponent(child);
    }

    public override function addComponentAt(child:Component, index:Int):Component {
        if (child != title && child != _content && child != _footer) {
            return _content.addComponentAt(child, index);
        }
        return null;
    }
}