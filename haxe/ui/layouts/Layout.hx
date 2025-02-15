package haxe.ui.layouts;

import haxe.ui.core.Component;
import haxe.ui.geom.Size;

class Layout implements ILayout {
    public function new() {

    }

    private var _component:Component;
    public var component(get, set):Component;
    private function get_component():Component {
        return _component;
    }
    private function set_component(value:Component):Component {
        _component = value;
        if (_component != null) {
            _component.invalidateComponentLayout();
        }
        return value;
    }

    private function findComponent<T:Component>(criteria:String = null, type:Class<T> = null, recursive:Null<Bool> = null, searchType:String = "id"):Null<T> {
        if (_component == null) {
            return null;
        }
        return _component.findComponent(criteria, type, recursive, searchType);
    }

    private function findComponents<T:Component>(styleName:String = null, type:Class<T> = null, maxDepth:Int = 5):Array<T> {
        if (_component == null) {
            return null;
        }
        return _component.findComponents(styleName, type, maxDepth);
    }
    
    @:access(haxe.ui.core.Component)
    public function refresh() {
        if (_component != null && _component.isReady == true) {

            resizeChildren();

            _component.handlePreReposition();
            repositionChildren();
            _component.handlePostReposition();
        }
    }

    public function autoSize():Bool {
        if (component.isReady == false) {
            return false;
        }

        var calculatedWidth:Null<Float> = null;
        var calculatedHeight:Null<Float> = null;
        if (component.autoWidth == true || component.autoHeight == true) {
            var size:Size = calcAutoSize();
            if (component.autoWidth == true) {
                calculatedWidth = size.width;
            }
            if (component.autoHeight == true) {
                calculatedHeight = size.height;
            }
            component.resizeComponent(calculatedWidth, calculatedHeight);
        }

        return (calculatedWidth != null || calculatedHeight != null);
    }

    //******************************************************************************************
    // Child helpers
    //******************************************************************************************
    private function marginTop(child:Component):Float {
        if (child == null || child.style == null || child.style.marginTop == null) {
            return 0;
        }
        return child.style.marginTop;
    }

    private function marginLeft(child:Component):Float {
        if (child == null || child.style == null || child.style.marginLeft == null) {
            return 0;
        }

        return child.style.marginLeft;
    }

    private function marginBottom(child:Component):Float {
        if (child == null || child.style == null || child.style.marginBottom == null) {
            return 0;
        }

        return child.style.marginBottom;
    }

    private function marginRight(child:Component):Float {
        if (child == null || child.style == null || child.style.marginRight == null) {
            return 0;
        }

        return child.style.marginRight;
    }

    private function childPaddingTop(child:Component):Float {
        if (child == null || child.style == null || child.style.paddingTop == null) {
            return 0;
        }
        return child.style.paddingTop;
    }

    private function childPaddingLeft(child:Component):Float {
        if (child == null || child.style == null || child.style.paddingLeft == null) {
            return 0;
        }

        return child.style.paddingLeft;
    }

    private function childPaddingBottom(child:Component):Float {
        if (child == null || child.style == null || child.style.paddingBottom == null) {
            return 0;
        }

        return child.style.paddingBottom;
    }

    private function childPaddingRight(child:Component):Float {
        if (child == null || child.style == null || child.style.paddingRight == null) {
            return 0;
        }

        return child.style.paddingRight;
    }
    
    private function hidden(c:Component = null):Bool {
        if (c == null) {
            c = component;
        }
        return c.hidden;
    }

    private function horizontalAlign(child:Component):String {
        if (child == null || child.style == null || child.style.horizontalAlign == null) {
            return "left";
        }
        return child.style.horizontalAlign;
    }

    private function verticalAlign(child:Component):String {
        if (child == null || child.style == null || child.style.verticalAlign == null) {
            return "top";
        }
        return child.style.verticalAlign;
    }

    private function fixedMinWidth(child:Component):Bool {
        var fixedMinWidth = false;
        if (child != null && child.style != null && child.style.minWidth != null) {
            fixedMinWidth = child.componentWidth <= child.style.minWidth;
        }
        return fixedMinWidth;
    }

    private function fixedMinHeight(child:Component):Bool {
        var fixedMinHeight = false;
        if (child != null && child.style != null && child.style.minHeight != null) {
            fixedMinHeight = child.componentHeight <= child.style.minHeight;
        }
        return fixedMinHeight;
    }

    //******************************************************************************************
    // Helper props
    //******************************************************************************************
    private var borderSize(get, null):Float;
    private function get_borderSize():Float {
        if (_component.style == null) {
            return 0;
        }

        var n = _component.style.fullBorderSize;
        if (n > 0) {
            //n--;
        }
        return n;
    }
    
    public var paddingLeft(get, null):Float;
    private function get_paddingLeft():Float {
        if (_component == null || _component.style == null || _component.style.paddingLeft == null) {
            return 0;
        }
        return _component.style.paddingLeft;
    }

    public var paddingTop(get, null):Float;
    private function get_paddingTop():Float {
        if (_component == null || _component.style == null || _component.style.paddingTop == null) {
            return 0;
        }
        return _component.style.paddingTop;
    }

    public var paddingBottom(get, null):Float;
    private function get_paddingBottom():Float {
        if (_component == null || _component.style == null || _component.style.paddingBottom == null) {
            return 0;
        }
        return _component.style.paddingBottom;
    }

    public var paddingRight(get, null):Float;
    private function get_paddingRight():Float {
        if (_component == null || _component.style == null || _component.style.paddingRight == null) {
            return 0;
        }
        return _component.style.paddingRight;
    }

    public var horizontalSpacing(get, null):Float;
    private function get_horizontalSpacing():Float {
        if (_component == null || _component.style == null || _component.style.horizontalSpacing == null) {
            return 0;
        }
        return _component.style.horizontalSpacing;
    }

    public var verticalSpacing(get, null):Float;
    private function get_verticalSpacing():Float {
        if (_component == null || _component.style == null || _component.style.verticalSpacing == null) {
            return 0;
        }
        return _component.style.verticalSpacing;
    }

    //******************************************************************************************
    // Helpers
    //******************************************************************************************
    public var innerWidth(get, null):Float;
    public var innerHeight(get, null):Float;

    // Inner width returns the size of the component minus padding
    private function get_innerWidth():Float {
        if (component == null) {
            return 0;
        }
        return component.componentWidth - (paddingLeft + paddingRight);
    }

    // Inner height returns the size of the component minus padding
    private function get_innerHeight():Float {
        if (component == null) {
            return 0;
        }
        var padding:Float = 0;
        if (component.style != null && component.style.paddingTop != null) {
            padding = component.style.paddingTop + padding;
        }
        if (component.style != null && component.style.paddingBottom != null) {
            padding = component.style.paddingBottom + padding;
        }
        var icy:Float = component.componentHeight - padding;
        return icy;
    }

    private function resizeChildren() {
    }

    private function repositionChildren() {
    }

    public var usableSize(get, null):Size;
    private function get_usableSize():Size {
        var ucx:Float = 0;
        if (_component.componentWidth != null) {
            ucx = _component.componentWidth;
            ucx -= paddingLeft + paddingRight;
        }

        var ucy:Float = 0;
        if (_component.componentHeight != null) {
            ucy = _component.componentHeight;
            ucy -= paddingTop + paddingBottom;
        }

        return new Size(ucx, ucy);
    }

    public var usableWidth(get, null):Float;
    private function get_usableWidth():Float {
        return usableSize.width;
    }

    public var usableHeight(get, null):Float;
    private function get_usableHeight():Float {
        return usableSize.height;
    }

    public function calcAutoWidth():Float {
        return calcAutoSize().width;
    }

    public function calcAutoHeight():Float {
        return calcAutoSize().height;
    }

    public function calcAutoSize(exclusions:Array<Component> = null):Size {
        var x1:Float = 0xFFFFFF;
        var x2:Float = 0;
        var y1:Float = 0xFFFFFF;
        var y2:Float = 0;
        for (child in component.childComponents) {
            if (child.includeInLayout == false || excluded(exclusions, child) == true) {
                continue;
            }

            if (child.percentWidth == null) {
                if (child.left < x1) {
                    x1 = child.left;
                }
                if (child.componentWidth != null && child.left + child.componentWidth > x2) {
                    x2 = child.left + child.componentWidth;
                }
            }

            if (child.percentHeight == null) {
                if (child.top < y1) {
                    y1 = child.top;
                }
                if (child.componentHeight != null && child.top + child.componentHeight > y2) {
                    y2 = child.top + child.componentHeight;
                }
            }
        }

        if (x1 == 0xFFFFFF) {
            x1 = 0;
        }
        if (y1 == 0xFFFFFF) {
            y1 = 0;
        }

        var w:Float = (x2 - x1) + (paddingLeft + paddingRight);
        var h:Float = (y2 - y1) + (paddingTop + paddingBottom);

        if ((this is AbsoluteLayout)) {
            w += x1;
            h += y1;
        }

        return new Size(w, h);
    }

    private function excluded(exclusions:Array<Component>, child:Component):Bool {
        if (exclusions == null || child == null) {
            return false;
        }
        return exclusions.indexOf(child) != -1;
    }
}