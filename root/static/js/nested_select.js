

/* ***************** For nested_select   **************************  */
var selected_datafile;

function select_datafile(id) 
{
  var old_slxn = $('datafile_' + selected_datafile);
  var new_slxn = $('datafile_' + id);
 

  if(old_slxn){
    old_slxn.className = "";
  };
  if(new_slxn){
     new_slxn.className = "selected"; 
  };
  selected_datafile = id;

  return false;
}

function set_selected_datafile(){
  $('selected_datafile').value = selected_datafile;
  return true;
}
