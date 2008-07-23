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

/* This is throwing firebug errors and I'm not using it now anyway.
Ajax.Autocompleter.set_linked_value = 
  function (linked_field_id, value_id) {
    new_val = $(value_id).firstChild;
    if (new_val){
       $(linked_field_id).value = new_val.nodeValue;
    }
};
*/


/***** ROME Stuff. *****/

   
/* tesco value cream cleaner uploader */

// set as your form's onsubmit callback:
function start_upload(div_id){
    $(div_id).innerHTML = '<span class="message">Please wait, uploading file...</span>';
}

//called by the results from the iframe defined in site/iframe_upload
function stop_upload(div_id, message){
    $(div_id).innerHTML = message;

}


function update_nav (){
  var nav_url = '/nav';
  var navAjax = new Ajax.Updater( 'nav', nav_url);
}

function update_status_bar (){
  var sb_url = '/status_bar';
  var sbAjax = new Ajax.Updater( 'status_bar', sb_url);
}

function update_experiment_list(divid,which,pattern){

    update_nav();
    update_status_bar(); 
    var el_url = '/experiment/search_like?pattern='+pattern+'&which='+which;
    var elAjax = new Ajax.Updater( divid, el_url );
    
}

function update_current_experiment(divid){
    var e_url = '/experiment/current';
    var eAjax = new Ajax.Updater(divid, e_url, {evalScripts:true});
}


function update_selected_datafiles(divid){
     var ul_url = '/crud/datafile/selected';
    var ulAjax = new Ajax.Updater(divid, ul_url, { evalScripts:true});
}

function update_datafile_list(divid){
    var dl_url = '/crud/datafile/graph';
    var dlAjax = new Ajax.Updater(divid, dl_url, {evalScripts:true});
}

/* function called by the Datafile controller when a datafile is selected*/
function datafile_updater (url){
    new Ajax.Updater ('messages', 
		      url, 
		      { asynchronous: 1,
			      onComplete: function(){update_nav(); update_status_bar(); update_datafile_list('list_datafiles'); update_selected_datafiles('selected_datafiles');  return false;},
			      evalScripts: true,
		      });
   
    return false;
}

// update the current user's workgroup list
function update_workgroup_list(divid){
    var wl_url = '/workgroup/list_user_workgroups';
    var wlAjax = new Ajax.Updater(divid,wl_url,{});
}

//update the list of pending joins for the wg
function update_pending_joins(divid,wg){
    var pj_url = '/workgroup/pending_joins/' + wg;
    var pjAjax = new Ajax.Updater(divid,pj_url,{});
}

//update the list of pending invites for the user
function update_pending_invites(divid){
    var pi_url = '/workgroup/pending_invites';
    var piAjax = new Ajax.Updater(divid, pi_url, {});
}


//update the list of queued jobs
function update_queued_jobs(divid){
    var qj_url = '/job/queue';
    var qjAjax = new Ajax.Updater(divid, qj_url, {});
}


//update the metadata factor list
function update_factor_list(divid){
  var f_url = '/metadata/factor/list';
  var fAjax = new Ajax.Updater(divid, f_url, {});
}


//update the metadata cont_var list
function update_cont_var_list(divid){
  var c_url = '/metadata/cont_var/list';
  var cAjax = new Ajax.Updater(divid, c_url, {}); 
}

//update the metadata outcome list
//need to evalScripts to re-register the dropables
function update_outcome_list(divid){
  var o_url = '/metadata/outcome/list';
  var oAjax = new Ajax.Updater(divid, o_url, {evalScripts:true}); 
}



//make the outcome drop boxes for the metadata controller
function make_dropable_outcome(divid){
    Droppables.add(divid,{
            Accept: ['level_drag','cont_var_drag'],
	    onDrop: function(e){
   		if (e.hasClassName('level_drag')){
                    //add this level to the outcome.
                    //level names can't have '-' in them, just \w (alphanum and _)
                    var res = e.id.split('-',3);
                    var fac_name=res[0];
                    var fac_owner=res[1];
                    var lev=res[2];

		    res = divid.split('-',2);
		    var outcome = res[1];

                    new Ajax.Updater('messages', 
                                     'metadata/outcome/add_level?outcome_name='+outcome+'&factor_name='+fac_name+'&factor_owner='+fac_owner+'&level_name='+lev,
				     {}
                     );                    
		}
                else if (e.hasClassName('cont_var_drag')){
                    var res = e.id.split('-',2);
                    var cont_var_name=res[0];
                    var cont_var_owner=res[1];

		    res = divid.split('-',2);
		    var outcome = res[1];

                    //get a value for this variable
                    var value = prompt("Please enter a value for this variable", "");
                    //add it to the outcome
                   new Ajax.Updater('messages', 
                                    'metadata/outcome/add_cont_var?outcome_name='+outcome+'&cont_var_name='+cont_var_name+'&cont_var_owner='+cont_var_owner+'&cont_var_value='+value,
				     {}
				     );   
	        }
                update_outcome_list('outcomes');
	    }

    });
} 

//make factor levels and cont_vars dragable.
function make_dragable_var(divid){
   new Draggable( divid, 
		  { ghosting: true, 
		    revert: true, 
			  scroll: window }); 
}

//delete a level of a factor from an outcome 
function delete_level(factor_name, factor_owner,level_name, outcome_name){
    new Ajax.Updater('messages', 
		     'metadata/outcome/delete_level?factor_name=' + factor_name
		     + '&factor_owner='+ factor_owner 
		     + '&level_name=' + level_name
		     + '&outcome_name=' + outcome_name,
		     {onComplete: function(){update_outcome_list('outcomes')} });
}


//delete a cont_var from an outcome 
function delete_cont_var(cont_var_name, cont_var_owner, outcome_name){
    new Ajax.Updater('messages', 
		     'metadata/outcome/delete_cont_var?cont_var_name=' + cont_var_name
		     + '&cont_var_owner='+ cont_var_owner 
		     + '&outcome_name=' + outcome_name,
		     {onComplete: function(){update_outcome_list('outcomes')} });
	}



//update the current_component section of the devel page
function update_current_component(divid){
    setTimeout(function(){
      var cc_url = '/devel/component/current';
      var ccAjax = new Ajax.Updater(divid, cc_url, {evalScripts:true});}, 1000);
}

//update the current_datatype section of the devel page
function update_current_datatype(divid){
    setTimeout(function(){
      var cd_url = '/devel/datatype/current';
      var cdAjax = new Ajax.Updater(divid, cd_url, {evalScripts:true});}, 1000);
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

      
