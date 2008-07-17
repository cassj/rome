/*********************************************************************************
  ROME js. Common to every page. 
*********************************************************************************/

/****
suckerfish dropdown IE Fix
*****/
sfHover = function() {
    	var sfEls = document.getElementById("nav_list").getElementsByTagName("LI");
	for (var i=0; i<sfEls.length; i++) {
		sfEls[i].onmouseover=function() {
			this.className+=" sfhover";
		}
		sfEls[i].onmouseout=function() {
			this.className=this.className.replace(new RegExp(" sfhover\\b"), "");
		}
	}
  
}
if (window.attachEvent) window.attachEvent("onload", sfHover);


/*****
 add onclick{return false} to inactive links  
******/
inactiveLink = function() 
{
  var nav= document.getElementById('nav');
  var links = nav.getElementsByTagName("A");
  for (var i=0; i<links.length; i++) { 
     if (links[i].className=="inactive"){
        links[i].onclick=function() {
           alert("Your datafile is the wrong datatype");
           return false;
        }
      }
  }
}

if (window.attachEvent) {
  window.attachEvent("onload", inactiveLink);
}
 else{
   window.addEventListener("load", inactiveLink, false);  
 }



function select_all(theCheckBox,theButton)
{
    var checkedValue;

    if(theButton.value == 'select all'){
        theButton.value = 'deselect all';
        checkedValue = true;
   }
   else{
        theButton.value = 'select all';
        checkedValue = false;
    }

    for(var i = 0; i < theCheckBox.length; i++){
       theCheckBox[i].checked = checkedValue;
    }
}

/* You don't need this for a single select/deselect button.
   See affyprobeset/form.tt for an example
*/
function deselect_all(theCheckBox, theButton){
    for(var i = 0; i < theCheckBox.length; i++){
       theButton.value = 'select all';
       theCheckBox[i].checked = false;
    }
}




/**** Additions to prototype/scriptaculous ***/


Ajax.Autocompleter.set_linked_value = 
  function (linked_field_id, value_id) {
    new_val = $(value_id).firstChild;
    if (new_val){
       $(linked_field_id).value = new_val.nodeValue;
    }
};


/***** ROME Stuff  *****/

   
function update_nav (){
  var nav_url = '/common/nav';
  var navAjax = new Ajax.Updater( 'nav', nav_url, { method: 'get'});
}

function update_status_bar (){
  var sb_url = '/common/status_bar';
  var sbAjax = new Ajax.Updater( 'status_bar', sb_url, { method: 'get'});
}



/****** dir_listing stuff **********/

toggle_sublist = function(element){
   var kids = element.getChildren;
   //this will break really easily tho,
   Element.toggle(element.nextSibling.nextSibling);
}


set_toggles = function(){

  var LIs = document.getElementsByTagName('LI');
  for (var i=0; i<LIs.length; i++) { 
      if (LIs[i].className=="toggle"){
        LIs[i].onclick=function(){
	  Element.toggle(this.nextSibling.nextSibling);
	}
        Element.hide(LIs[i].nextSibling.nextSibling);
      
      } 
  }
}
 

/* 
   //find those which have dir_list class
   for (var i=0; i<DLs.length; i++) { 
     if (ULs[i].className=="dir_list"){
        //grab any titles
        var titles = LIs[i].getElementsByTagName('LI');
           for (var j=0; j<titles.length; j++) { 
             //set them to dropdown on click
             titles[i].onclick=function() {
                  alert("Hello there!");
                  return false;
                 }
           }		 
     }
   }
}

*/


if (window.attachEvent) {
  window.attachEvent("onload", set_toggles);
}
 else{
   window.addEventListener("load", set_toggles, false);  
 }





/******* DEBUG *************/
       var MAX_DUMP_DEPTH = 10;

      
function dumpObj(obj, name, indent, depth) {

  if (depth > MAX_DUMP_DEPTH) {
     return indent + name + ": <Maximum Depth Reached>\n";

  }

  if (typeof obj == "object") {

     var child = null;
     var output = indent + name + "\n";
     indent += "\t";

     for (var item in obj)
     {
       try {
              child = obj[item];
           } catch (e) {
              child = "<Unable to Evaluate>";
           }
 
       if (typeof child == "object") {
          output += dumpObj(child, item, indent, depth + 1);
       } else {
          output += indent + item + ": " + child + "\n";
       }
      }

  return output;
  } else {
     return obj;
  }

}

      
