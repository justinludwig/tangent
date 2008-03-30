
var I = {

personalize: function() {
	var c = document.cookie.match(/tangent_person=(.*?)(?:;|$)/);
	if (!c) return;
	
	eval("I.p={" + decodeURIComponent(c[1]) + "}");
	
	function $(id) { return document.getElementById(id); }
	
	function show(id, d) {
		var e = $(id);
		if (e)
			e.style.display = d ? "" : "none";
	}
	
	var profile = $("my-profile");
	if (profile)
		profile.href = "/people/" + I.p.id;
		
	var name = $("person-name");
	if (name)
		name.innerHTML = I.p.name;
	
	show("my", 1);
	show("person", 1);
	show("anon", 0);
},

logout: function() {
	I.xhr("GET", "/sessions/authenticity_token", "", "", function(xhr) {
		var t = xhr.responseText;
	
        var f = document.createElement('form');
        f.style.display = 'none';
        document.body.appendChild(f);
        f.method = 'POST';
        f.action = '/session';
        
        var m = document.createElement('input');
        m.setAttribute('type', 'hidden');
        m.setAttribute('name', '_method');
        m.setAttribute('value', 'delete');
        f.appendChild(m);
        
        var s = document.createElement('input');
        s.setAttribute('type', 'hidden');
        s.setAttribute('name', 'authenticity_token');
        s.setAttribute('value', t);
        f.appendChild(s);
        
        f.submit();
    });
    
    return false;
},

xhr: function(method, url, params, body, callback) {
	try { var x = new XMLHttpRequest(); } catch (e) { 
	try { var x = new ActiveXObject("Msxml2.XMLHTTP"); } catch (e) {
	try { var x = new ActiveXObject("Microsoft.XMLHTTP"); } catch (e) {
		return null;
	}}}
	
	url = (url ? url : "/");
	method = (method ? method.toUpperCase() : "GET");
	x.open(method, url + (params ? (/\?/.test(url) ? "&" : "?") + params : ""), true);
	
	if (body)
        x.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	
	var done;
	if (callback)
    	x.onreadystatechange = function() {
    		if (x.readyState != 4 || done) return;
    		
            setTimeout(function() { callback(x); }, 10);
            done = true;
    	};
	
	x.send(body);
	return x;
}
 
}; // end I
