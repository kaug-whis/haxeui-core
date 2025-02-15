package haxe.ui.core;

import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;

class BasicItemRenderer extends ItemRenderer {
    public function new() {
        super();

        var hbox:HBox = new HBox();
        hbox.addClass("basic-renderer-container");

        var icon:Image = new Image();
        icon.id = "icon";
        icon.addClass("basic-renderer-icon");
        icon.verticalAlign = "center";
        icon.hide();
        hbox.addComponent(icon);

        var label:Label = new Label();
        label.id = "text";
        label.addClass("basic-renderer-label");
        label.verticalAlign = "center";
        label.hide();
        hbox.addComponent(label);

        addComponent(hbox);
    }
}
