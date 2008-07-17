/* dropdown - toggles display between none and block for the element.style 
   I think this is probably perfectly adequately covered by dojo.js
*/

function dropdown(elmt_id) {
		if (document.getElementById) {
		    var elmt = document.getElementById(elmt_id);
		    //var elmt_pm = $('plus_minus_'+elmt_id);
		     
		    if (elmt.style.display == "block") {
		      elmt.style.display = "none";
		      // elmt_pm.innerHTML = '+';
		    }
		    else {
		      elmt.style.display = "block";
		      // elmt_pm.innerHTML = '-';
			}
		    return false
		    } else {
			return true
			}
	    }
