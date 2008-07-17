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


