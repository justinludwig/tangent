// Tangent, an online sign-up sheet
// Copyright (C) 2008 Justin Ludwig and Adam Stuenkel
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
// 02110-1301, USA.

var App = {

/**
 * Init app javascript.
 */
init: function() {
    var loader = new YAHOO.util.YUILoader({
        loadOptional: true,
        onSuccess: function() {
            /*
            // move non-yui css files (those without an id) below yui css (giving non-yui greater precedence)
            var head = document.getElementsByTagName("head")[0];
            var links = [];
            for (var i = 0, e, elements = head.getElementsByTagName("link"); e = elements[i]; i++)
                if (!e.id)
                    links.push(e);
            for (var i = 0, e; e = links[i]; i++)
                head.appendChild(e);
            */

            YAHOO.util.Event.onDOMReady(function() {
                // init yui-push-buttons
                for (var i = 0, e, elements = YAHOO.util.Selector.query("span.yui-push-button"); e = elements[i]; i++)
                    new YAHOO.widget.Button(e);
            });

            App.inited = true;
            App.onInit.fire();
        },
        require: [
            "animation",
            "button",
            "calendar",
            "connection",
            "cookie",
            "container",
            "dom",
            "dragdrop",
            "editor",
            "element",
            "json",
            "menu",
            "resize",
            "selector"
        ]
    });
    loader.insert();
},

/**
 * Event fired when app finished initing.
 */
onInit: new YAHOO.util.CustomEvent("App.onInit"), 

/**
 * Invokes fn when app inited, or now if already inited.
 */
waitUntilInited: function(fn) {
    if (App.inited)
        fn();
    else
        onInit.subscribe(fn);
},

/**
 * Invokes the specified rails controller request.
 */
controllerRequest: function(method, url, params) {
    method = (method ? method.toLowerCase() : "get");
    url = url || document.location.href;

    if (params) 
        url = url + (/\?/.test(url) ? "&" : "?") + params;

    if (method == "get") {
        document.location.href = url;
        return;
    }

    var f = document.createElement("form");
    f.style.display = "none";
    document.body.appendChild(f);
    f.method = "post";
    f.action = url;
    
    var m = document.createElement("input");
    m.setAttribute("type", "hidden");
    m.setAttribute("name", "_method");
    m.setAttribute("value", method);
    f.appendChild(m);
    
    var s = document.createElement("input");
    s.setAttribute("type", "hidden");
    s.setAttribute("name", "authenticity_token");
    s.setAttribute("value", App.authenticity_token);
    f.appendChild(s);
    
    f.submit();
},

/**
 * Focuses the first input field in the specified element.
 */
focusFirstInput: function(form) {
    form = $y(form);

    function focus(e) {
        try {
            e.focus();
            try {
                e.select();
            } catch (x) {}
            return true;
        } catch (x) {}
        return false;
    }

    var inputs = form.getElementsByTagName("input");
    function focusInputType(type) {
        for (var i = 0, e; e = inputs[i]; i++)
            if (type.test(e.type) && !e.disabled && focus(e))
                return true;
        return false;
    }

    function focusElementType(type) {
        for (var i = 0, e, elements = form.getElementsByTagName(type); e = elements[i]; i++)
            if (!e.disabled && focus(e))
                return true;
        return false;
    }

    if (
        focusInputType(/text|password|^$/) ||
        focusElementType("textarea") ||
        focusElementType("select") ||
        focusInputType(/checkbox|radio|file/) ||
        focusElementType("button") ||
        focusInputType(/button|submit|image|reset/)
    );
    return form;
},

/**
 * Displays a (non-blocking) alert dialog.
 * @param msg (optional) Alert message.
 * @param ok (optional) OK button config: { text: "OK", handler: function() { this.hide(); this.destroy(); } }.
 * @param title (optional) Dialog title.
 * @param icon (optional) Dialog icon url.
 */
alert: function(msg, ok, title, icon) {
    msg = msg || "Uh-oh!";
    title = title || "Alert";

    ok = YAHOO.lang.merge({
        text: "OK",
        handler: function() {
            this.hide();
            this.destroy();
        }
    }, ok || {});

    var d = new YAHOO.widget.SimpleDialog("alert", {
        buttons: [ ok ],
        close: false,
        constraintoviewport: true,
        draggable: true,
        fixedcenter: true,
        icon: icon,
        keyListeners: [
            new YAHOO.util.KeyListener(document, {
                keys: [13, 27] // enter, escape
            }, function() {
                ok.handler.call(d);
            })
        ],
        modal: true,
        text: msg,
        visible: true,
        width: "333px"
    });

    d.setHeader(title);
    d.render(document.body);

    setTimeout(function() {
        App.focusFirstInput("alert");
    }, 100);
},

/**
 * Displays a (non-blocking) confirmation dialog.
 * @param msg (optional) Confirmation question.
 * @param ok (optional) OK button config: { text: "OK", handler: function() { this.hide(); this.destroy(); } }.
 * @param cancel (optional) Cancel button config: { text: "Cancel", handler: function() { this.hide(); this.destroy(); } }.
 * @param title (optional) Dialog title.
 * @param icon (optional) Dialog icon url.
 */
confirm: function(msg, ok, cancel, title, icon) {
    msg = msg || "Are you sure?";
    title = title || "Confirm";
    //icon = icon || YAHOO.widget.SimpleDialog.ICON_WARN;

    ok = YAHOO.lang.merge({
        text: "OK",
        //isDefault: true,
        handler: function() {
            this.hide();
            this.destroy();
        }
    }, ok || {});

    cancel = YAHOO.lang.merge({
        text: "Cancel",
        handler: function() {
            this.hide();
            this.destroy();
        }
    }, cancel || {});

    var d = new YAHOO.widget.SimpleDialog("confirm", {
        buttons: [ ok, cancel ],
        close: false,
        constraintoviewport: true,
        draggable: true,
        /*
        effect: {
            effect: YAHOO.widget.ContainerEffect.FADE, 
            duration: 0.3
        },
        */
        fixedcenter: true,
        icon: icon,
        keyListeners: [
            new YAHOO.util.KeyListener(document, {
                keys: 13 // enter
            }, function() {
                ok.handler.call(d);
            }),
            new YAHOO.util.KeyListener(document, {
                keys: 27 // escape
            }, function() {
                cancel.handler.call(d);
            })
        ],
        modal: true,
        text: msg,
        visible: true,
        width: "333px"
    });

    d.setHeader(title);
    d.render(document.body);

    setTimeout(function() {
        App.focusFirstInput("confirm");
    }, 100);
},

/**
 * Displays a (non-blocking) prompt dialog.
 * @param msg (optional) Prompt text.
 * @param dflt (optional) Default value.
 * @param ok (optional) OK button config: { text: "OK", handler: function() { this.hide(); this.destroy(); } }.
 * @param cancel (optional) Cancel button config: { text: "Cancel", handler: function() { this.hide(); this.destroy(); } }.
 * @param title (optional) Dialog title.
 * @param input (optional) Input form html.
 */
prompt: function(msg, dflt, ok, cancel, title, input) {
    title = title || "Prompt";

    ok = YAHOO.lang.merge({
        text: "OK",
        handler: function() {
            this.hide();
            this.destroy();
        }
    }, ok || {});

    cancel = YAHOO.lang.merge({
        text: "Cancel",
        handler: function() {
            this.hide();
            this.destroy();
        }
    }, cancel || {});

    input = input || "<form id='prompt-form'>" + (msg ? "<label for='prompt-value'>" + msg + "</label>" : "") + "<input id='prompt-value' name='prompt-value' type='text' value='" + (dflt || "") + "' style='width:300px' /></form>";

    var d = new YAHOO.widget.SimpleDialog("prompt", {
        buttons: [ ok, cancel ],
        close: false,
        constraintoviewport: true,
        draggable: true,
        fixedcenter: true,
        keyListeners: [
            new YAHOO.util.KeyListener(document, {
                keys: 13 // enter
            }, function() {
                ok.handler.call(d);
            }),
            new YAHOO.util.KeyListener(document, {
                keys: 27 // escape
            }, function() {
                cancel.handler.call(d);
            })
        ],
        modal: true,
        visible: true,
        width: "333px"
    });

    d.setHeader(title);
    d.setBody(input);
    d.render(document.body);

    setTimeout(function() {
        App.focusFirstInput("prompt");
    }, 100);
}

}; // end App

/** Alias for new YAHOO.util.Element. */
var $y = function(e) {
    return new YAHOO.util.Element(e);
};

