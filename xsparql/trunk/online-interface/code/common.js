function clearquery()
{
    document.getElementById('query').value="";
    document.getElementById('URI').value="";

}

function togglebutton(state)
{
    if (state == "on")
    {
        document.getElementById("evalbutton").innerHTML = "<b><a href=\"#\" onClick=\"javascript:evalquery(); return false;\">[Run it!]</a></b>";
    }
    else
    {
        document.getElementById("evalbutton").innerHTML = "<b>[Run it!]</b>";
    }
}

function evalquery()
{

    window.self.location.hash="#result"

    ajax.StartProgress(500, "rewriter/solver is processing... slow machine, sorry ;-)");

    togglebutton('off');

    document.getElementById("result").style.display = 'block';
    document.getElementById("result").innerHTML = 'computing...';

/*
    radios = document.getElementsByName('solver');
    for (i = 0; i < radios.length; i++)
    {
        if (radios[i].checked)
            sol = radios[i].value;
    }
    */

    var poststr = "query=" + escape(document.getElementById('query').value) +
                  "&URI=" + escape(document.getElementById('URI').value) +
                  "&solver=" + solverToSet;

    // javascript 'escape' doesn't escape plus:
    poststr = poststr.replace(/\+/g,"%2B");

    //new ajax("eval.php", {postBody: poststr, update: $('result')});
    new ajax("eval.pl", {postBody: poststr, onComplete: updateresult});
}

function loadfile(name)
{

    var poststr = "filename=" + name;

    // set solver from extension
    switch (name.substring(name.lastIndexOf('.')+1, name.length))
    {
    case "evaluate": 
        solverToSet = 'evaluate';
        break;
    case "rewrite":
        solverToSet = 'rewrite';
        break;
    default:
        break;
    }

    //solverToSet = 'evaluate';

    new ajax("loadfile.php", {postBody: poststr, onComplete: updatequery});
}


function updatequery(resp)
{
    query = resp.responseText;
    solverstring = "";
    switchesline = query.substr(0, query.indexOf("\n"));
    switches = switchesline.split("|");
    
    solverstring = switches[0].toLowerCase();

     //   solverToSet = "evaluate";

    switch (solverstring)
    {
    case "evaluate":
        solverToSet = "evaluate";
        break;
    case "rewrite":
        solverToSet = "rewrite";
        break;
    default:
        break;
    }

    //setSolver();
    togglesolver(solverToSet);

    // strip switches from program:
    query=query.substring(query.indexOf("\n")+1);

    document.getElementById('query').value = query;
    document.getElementById('URI').value=switches[1];
}

function updateresult(resp)
{
    document.getElementById('result').innerHTML = resp.responseText;

    togglebutton('on');

    // clear filter:
    //document.getElementById('filter').value = "";
    ajax.EndProgress();

    window.self.location.hash="#result"
}

function buttonpress(el, on)
{
    if (on)
    {
        el.style.backgroundColor = "#b0b0b0";
        el.style.borderTopColor = "#303030";
        el.style.borderLeftColor = "#303030";
        el.style.borderBottomColor = "#b0b0b0";
        el.style.borderRightColor = "#b0b0b0";
    }
    else
    {
        el.style.backgroundColor = "#e0e0e0";
        el.style.borderTopColor = "#b0b0b0";
        el.style.borderLeftColor = "#b0b0b0";
        el.style.borderBottomColor = "#303030";
        el.style.borderRightColor = "#303030";
    }
}


function togglesolver(buttonid)
{
    solverToSet = buttonid;

    //alert(buttonid);

    var buts = document.getElementsByClassName('solverbutton');

    buts.each(function(el, i){
            buttonpress(el, (el.id == solverToSet));
    });

}

// ----- show or hide a progress indicator -----

ajax.progress = false; /// show a progress indicator
ajax.progressTimer = null; /// a timer-object that help displaying the progress indicator not too often.

// show a progress indicator if it takes longer...
ajax.StartProgress = function(pre, text) {
  ajax.progress = true;
  if (ajax.progressTimer != null)
    window.clearTimeout(ajax.progressTimer);
  ajax.progressTimer = window.setTimeout('ajax.ShowProgress("'+text+'")', pre);
} // ajax.StartProgress


// hide any progress indicator soon.
ajax.EndProgress = function () {
  ajax.progress = false;
  if (ajax.progressTimer != null)
    window.clearTimeout(ajax.progressTimer);
  ajax.progressTimer = window.setTimeout(ajax.ShowProgress, 200);
} // ajax.EndProgress 


// this function is called by a timer to show or hide a progress indicator
ajax.ShowProgress = function(text) {
  ajax.progressTimer = null;
  var a = document.getElementById("AjaxProgressIndicator");
  
  if (ajax.progress && (a != null)) {
    // just display the existing object
    a.style.display = "";
    a.innerHTML = "<p><img src='images/waiting.gif'></p>" + text;
    
  } else if (ajax.progress) {
    // create new standard progress object
    a = document.createElement("div");
    a.id = "AjaxProgressIndicator";
    a.style.position = "absolute";
    var r,t;
    if (self.innerHeight) { // all except Explorer
        r = self.innerWidth; t = self.innerHeight;
    }
    else if (document.documentElement && document.documentElement.clientHeight) {
        // Explorer 6 Strict Mode
        r = document.documentElement.clientWidth; t = document.documentElement.clientHeight;
    }
    else if (document.body) { // other Explorers
        r = document.body.clientWidth; t = document.body.clientHeight;
    }
    r = 700;
    r = r / 2 - 70; t = t / 2 - 40;
    a.style.left = r + "px";
    a.style.top = t + "px";
    a.style.width = "170px";
    a.style.padding = "14px";
    a.style.border = "1px solid #a0a0a0";
    a.style.backgroundColor="#ffffff";

    a.innerHTML = "<p><img src='images/waiting.gif'></p>" + text;
    document.getElementById('Wrapper').appendChild(a);

  } else if (a) {
    a.style.display = "none";
  } // if
} // ajax.ShowProgress


/* IE only!
function togglediv(id)
{
    if (document.getElementById(id).style.display == 'block')
        document.getElementById(id).style.display = 'none'
    else
        document.getElementById(id).style.display = 'block'
}

function initPosition(textBox)
{
    var storedValue = textBox.value;
    textBox.value = "";
    textBox.select();

    var caretPos = document.selection.createRange();
    textBox.__boundingTop = caretPos.boundingTop;
    textBox.__boundingLeft = caretPos.boundingLeft;

    textBox.value = " ";
    textBox.select();

    caretPos = document.selection.createRange();
    textBox.__boundingWidth = caretPos.boundingWidth;
    textBox.__boundingHeight = caretPos.boundingHeight;

    textBox.value = storedValue;
}

function storePosition(textBox)
{
    var caretPos = document.selection.createRange();

    var boundingTop = (caretPos.offsetTop + textBox.scrollTop) - textBox.__boundingTop;
    var boundingLeft = (caretPos.offsetLeft + textBox.scrollLeft) - textBox.__boundingLeft;

    textBox.__Line = (boundingTop / textBox.__boundingHeight) + 1;
    textBox.__Column = (boundingLeft / textBox.__boundingWidth) + 1;
} 



function updatePosition(textBox)
{
    storePosition(textBox);
    document.getElementById('txtline').txtLine.value = textBox.__Line;
    document.getElementById('txtcol').txtColumn.value = textBox.__Column;
}
*/
