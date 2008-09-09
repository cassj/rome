/******

  component/primerdesign/single_primer_pair

 ******/
toggle_sublist = function(element){
   var kids = element.getChildren;
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
 

if (window.attachEvent) {
  window.attachEvent("onload", set_toggles);
}
 else{
   window.addEventListener("load", set_toggles, false);  
 }


