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

/** App context-path, such as "/tangent". */
contextPath: "",

/**
 * Init app javascript.
 */
init: function() {
    var loader = new YAHOO.util.YUILoader({
        loadOptional: true,
        onSuccess: function() {
            // alias YAHOO.util.Dom.get
            if (typeof($) == "undefined")
                window.$ = YAHOO.util.Dom.get;

            YAHOO.util.Event.onDOMReady(function() {
                // init yui-push-buttons
                for (var i = 0, e, elements = YAHOO.util.Selector.query("span.yui-push-button"); e = elements[i]; i++)
                    new YAHOO.widget.Button(e);

                // init date-time inputs
                for (var i = 0, e, elements = YAHOO.util.Selector.query("span.datetime-input"); e = elements[i]; i++)
                    App.Cal.convert(e);
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
    form = $(form);

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
 * Creates the specified element.
 * @param tag Element tag name ("span").
 * @param attrs (optional) Map of element attributes ({ id: "foo", "class": "bar }).
 * @param text (optional) Element text content.
 * @param unescaped (optional) True if specified text content shouldn't be escaped. 
 * @return New element.
 */
createElement: function(tag, attrs, text, dontEscape) {
    var e = document.createElement(tag);
    for (var i in attrs)
        App.setAttribute(e, i, attrs[i]);

    if (text) {
        if (dontEscape)
            e.innerHTML = text;
        else
            e.appendChild(document.createTextNode(text));
    }

    return e;
},

/**
 * Gets the specified element attribute as a string value.
 * Fixes ie's non-standard getAttribute() behavior.
 * @param element Element object.
 * @param qname Attribute name.
 * @param ns (optional) Attribute namespace.
 * @param localname (optional) Attribute local name.
 * @return String attribute value or "".
 */
getAttribute: function(element, qname, ns, localname) {
    if (qname == "class")
        return element.className;
    if (qname == "style")
        return element.style.cssText;

    if (ns && element.getAttributeNS) {
        var value = element.getAttributeNS(ns, localname);
    } else try {
        value = element.getAttribute(qname);
    } catch (e) {
        // ie doesn't like prefixed attributes on certain element types
        value = element.getAttribute(qname.replace(/:/, "."));
    }
    return String(value || "");
},

/**
 * Sets the specified element attribute as a string value.
 * Fixes ie's non-standard setAttribute() behavior.
 * @param element Element object.
 * @param qname Attribute name.
 * @param value String attribute value.
 * @param ns (optional) Attribute namespace.
 * @param localname (optional) Attribute local name.
 */
setAttribute: function(element, qname, value, ns, localname) {
    var useNS = ns && element.getAttributeNS;

    // special attributes
    if (qname == "class") {
        element.className = value || "";
        return;
    }
    if (qname == "style") {
        element.style.cssText = value || "";
        return;
    }
    // remove instead of setting to null
    if (value == null) {
        if (useNS)
            element.removeAttributeNS(ns, localname);
        else try {
            element.removeAttribute(qname);
        } catch (e) {
            // ie doesn't like prefixed attributes on certain element types
            element.removeAttribute(qname.replace(/:/, "."));
        }
        return;
    }

    var oldValue;
    if (useNS) {
        oldValue = element.getAttributeNS(ns, localname);
    } else try {
        oldValue = element.getAttribute(qname);
    } catch (e) {
        // ie doesn't like prefixed attributes on certain element types
        oldValue = element.getAttribute(qname.replace(/:/, "."));
    }

    // cast to appropriate type for ie
    var type = typeof(oldValue);
    if (type == "boolean")
        value = (value && !/false/i.test(value))
    else if (type == "number")
        value = Number(value);

    if (value == oldValue)
        return;

    if (useNS) {
        element.setAttributeNS(ns, qname, value);
    } else try {
        element.setAttribute(qname, value);
    } catch (e) {
        element.setAttribute(qname.replace(/:/, "."), value);
    }
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

/** Date-picker functionality. */
App.Cal = {

/**
 * Converts a plain-jane text input into a fancy date-time picker.
 * @param element Span surrounding the text input.
 */
convert: function(element) {
    element = $(element);
    var input = element.getElementsByTagName("input")[0];
    var id = input.id, hiddenId = id + "__hidden";
    // skip if already converted
    if ($(hiddenId)) return;

    // adjust UTC date to browser timezone, format as pretty date
    var date = Date.parse(input.value);
    if (date) {
        var tz = date.getTimezoneOffset();
        if (tz)
            date.addMinutes(-tz);
        input.value = date.toShortDateString() + " " + date.toShortTimeString();
    }

    // remove input name, add to hidden input
    var name = input.name;
    input.name = null;
    element.appendChild(App.createElement("input", {
        id: hiddenId,
        type: "hidden",
        name: name
    }));

    /*
    var abbr = YAHOO.lang.trim((new Date().toString().match(/([^\d()-+:\/]+)[\s\d()-+:\/]*$/)||["",""])[1].replace(/^\s*[AP]M\s/, ""));
    if (!abbr)
        abbr = "UTC" + new Date().getUTCOffset();
    element.appendChild(App.createElement("span", {
        id: id + "__timezone",
        "class": "timezone"
    }, abbr));
    */

    // add calendar popup
    element.appendChild(App.createElement("a", {
        id: id + "__calendar",
        href: "javascript:App.Cal.show('" + id + "','" + id + "__calendar')",
        "class": "calendar"
    })).appendChild(App.createElement("img", {
        src: App.contextPath + "/images/silk/calendar.png",
        alt: "Select Date",
        title: "Select Date"
    }));

    // add parsed result display
    element.appendChild(App.createElement("span", {
        id: id + "__display",
        "class": "display"
    }));

    // update hidden input and result display
    App.Cal.update(input);

    // create popup calendar (delay a little cause we don't need right away)
    setTimeout(function() {
        var containerId = id + "__calendar_container";
        element.appendChild(App.createElement("div", {
            id: containerId,
            "class": "calendar-container"
        }));
        
        var calendar = App[id + "__calendar"] = new YAHOO.widget.Calendar(containerId, {
            close: true,
            navigator: true,
            pagedate: (date ? date.toString("MM/yyyy") : ""),
            selected: (date ? date.toString("MM/dd/yyyy") : ""),
            title: "Select Date"
        });
        calendar.render();

        calendar.selectEvent.subscribe(App.Cal.select, input);
    }, 1000);

    // register events
    // keydown instead of keypress cause ie fires keypress only for alphanumeric keys
    YAHOO.util.Event.on(input, "keydown", App.Cal.keypress);
},

/** Timer object from YAHOO.lang.later. */
lastKeypress: {
    cancel: function() {}
},

/**
 * Handles keypress event in date-picker input.
 */
keypress: function(event) {
    App.Cal.lastKeypress.cancel();
    App.Cal.lastKeypress = YAHOO.lang.later(300, this, App.Cal.update);
},

/**
 * Handles select event on calendar popup.
 */
select: function(type, args, input) {
    // hide the calendar
    var calendar = App[input.id + "__calendar"];
    if (calendar) {
        // skip when updated via text input
        if (calendar.supressNextSelect) {
            delete calendar.supressNextSelect;
            return;
        }
        calendar.hide();
    }

    var selected = args[0][0];

    // convert calendar popup's array to date object
    var date = Date.parse(input.value) || new Date();
    date.setFullYear(selected[0]);
    date.setMonth(selected[1] - 1);
    date.setDate(selected[2]);

    // ignore if date is same as current value
    var value = date.toShortDateString() + " " + date.toShortTimeString();
    if (input.value == value) return;

    input.value = value;
    App.Cal.update(input);
},

/**
 * Updates the specified date picker.
 * @param input The original date-picker input.
 */
update: function(input) {
    input = $(input) || this;
    var id = input.id;
    var date = Date.parse(input.value) || "";

    // calculate timezone abbreviation
    if (!App.Cal.abbr) {
        App.Cal.abbr = YAHOO.lang.trim((new Date().toString().match(/([^\d()-+:\/]+)[\s\d()-+:\/]*$/)||["",""])[1].replace(/^\s*[AP]M\s/, ""));
        if (!App.Cal.abbr)
            App.Cal.abbr = "UTC" + new Date().getUTCOffset();
    }

    // update hidden input
    var hidden = $(id + "__hidden");
    if (hidden)
        hidden.value = (date ? date.toISOString() : "");

    // update parsed result display
    var display = $(id + "__display");
    if (display)
        display.innerHTML = (date ? date.toLongDateString() + " " + date.toShortTimeString() + " " + App.Cal.abbr : "No Date");

    // update calendar popup
    var calendar = App[id + "__calendar"];
    if (calendar) {
        calendar.supressNextSelect = true;
        calendar.select(date);
        if (date)
            calendar.cfg.setProperty("pagedate", date.toString("MM/yyyy")); 
        calendar.render();
    }
},

/**
 * Shows the calendar for the specified date-picker input.
 */
show: function(input, near) {
    input = $(input)
    near = $(near) || input;
    var id = input.id
    var container = $(id + "__calendar_container");
    if (container) {
        var xy = YAHOO.util.Dom.getXY(near);
        container.style.left = xy[0] + "px";
        container.style.top = (xy[1] + near.offsetHeight) + "px";
    }

    var calendar = App[id + "__calendar"];
    if (calendar)
        calendar.show();
}

}; // end Cal

