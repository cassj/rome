

/*******
Factor and level stuff.
*******/

var factors = new Array();

function add_factor_input(){


  factors.push(0);  
  var fac_num = String(factors.length);

  //fac div
  var fac_div = document.createElement('div');
  fac_div.setAttribute('id', 'fac_'+ fac_num );
  fac_div.setAttribute('class', 'factor');
  
  //make header 
  var header = document.createElement('p');
  header.setAttribute('class','mainTitle');
  var header_text = document.createTextNode('Factor '+fac_num);
  header.appendChild(header_text);
  fac_div.appendChild(header);

  //make name
  var name_div = document.createElement('div');
  name_div.setAttribute('class', 'labelled_input');  
  var name_label = document.createElement('label');
  name_label.setAttribute('for','name_fac'+ fac_num);
  var name_label_text = document.createTextNode('Name: ');
  var name_input = document.createElement('input');
  name_input.setAttribute('type','text');
  name_input.setAttribute('name','name_fac'+fac_num);
  name_input.setAttribute('value', 'factor '+fac_num);

 
  //append name  
  name_label.appendChild(name_label_text);
  name_div.appendChild(name_label);
  name_div.appendChild(name_input);
  fac_div.appendChild(name_div);
  
  //make description
  var desc_div = document.createElement('div');
  desc_div.setAttribute('class', 'labelled_input');
  var desc_label = document.createElement('label');
  desc_label.setAttribute('for', 'desc_fac'+fac_num);
  var desc_label_text = document.createTextNode('Description');
  var desc_input = document.createElement('input');
  desc_input.setAttribute('type', 'text');
  desc_input.setAttribute('name', 'desc_fac'+fac_num);
  desc_input.setAttribute('value', 'factor '+fac_num);

  //append description
  desc_label.appendChild(desc_label_text);
  desc_div.appendChild(desc_label);
  desc_div.appendChild(desc_input);
  fac_div.appendChild(desc_div);

  //make timecourse checkbox
  var checkbox_div = document.createElement('div');
  checkbox_div.setAttribute('class' , 'labelled_input');
  var checkbox_label = document.createElement('label');
  checkbox_label.setAttribute('for' ,'cont_fac'+fac_num);
  var checkbox_label_text = document.createTextNode('Time course?');
  var checkbox_input = document.createElement('input');
  checkbox_input.setAttribute('type', 'checkbox');
  checkbox_input.setAttribute('name', 'cont_fac'+fac_num);
    
  //append checkbox
  checkbox_label.appendChild(checkbox_label_text);
  checkbox_div.appendChild(checkbox_label);
  checkbox_div.appendChild(checkbox_input);
  fac_div.appendChild(checkbox_div);
    
  //make and append add_level button
  var level_button = document.createElement('input');
  level_button.setAttribute('type', 'button');
  level_button.setAttribute('class', 'level_button');
  level_button.setAttribute('value', 'Create level...');
  level_button.setAttribute('onClick', 'add_level_input('+fac_num+');');
  fac_div.appendChild(level_button);

  var line_break = document.createElement('br');
  fac_div.appendChild(line_break);
  
  //make and append level div
  var lev_div = document.createElement('div');
  fac_div.appendChild(lev_div);

  //make and append clear div
   var clear_div = document.createElement('div');
   clear_div.setAttribute('class','force_clear');
   fac_div.appendChild(clear_div);

  //append everything   
  $('new_factor_list').appendChild(fac_div);
}


function add_level_input(fac){

  var parent_div =  $('fac_'+fac);
  //    var div = $('fac_'+fac+'_levels');
        
    //increment your level count.
    factors[fac-1] = factors[fac-1] + 1;  
    var lev = factors[fac-1];

    var div = document.createElement('div');
    div.setAttribute('id', 'fac_'+fac+'_levels');
    div.setAttribute('class', 'levels');
 
    var header = document.createElement('p');
    header.setAttribute('class','subTitle');
    var header_text =  document.createTextNode('Level '+ lev);
    header.appendChild(header_text);
    div.appendChild(header);
   
    var name_div = document.createElement('div');
    name_div.setAttribute('class', 'labelled_input');
    var name_label = document.createElement('label');
    name_label.setAttribute('for', 'name_fac'+fac+'_lev'+lev);
    var name_label_text = document.createTextNode('Name:');
    var name_input = document.createElement('input'); 
    name_input.setAttribute('type','text');
    name_input.setAttribute('name', 'name_fac'+fac+'_lev'+lev);
    name_input.setAttribute('value', 'level '+lev);
 
    name_label.appendChild(name_label_text);
    name_div.appendChild(name_label);
    name_div.appendChild(name_input);
    div.appendChild(name_div);  
 
    var desc_div = document.createElement('div');
    desc_div.setAttribute('class','labelled_input');
    var desc_label = document.createElement('label');
    desc_label.setAttribute('for','desc_fac'+fac+'_lev'+lev);
    var desc_label_text = document.createTextNode('Description: ');
    var desc_input = document.createElement('input');
    desc_input.setAttribute('type', 'text');
    desc_input.setAttribute('name' , 'desc_fac'+fac+'_lev'+lev);
    desc_input.setAttribute('value', 'level '+lev);
     
    desc_label.appendChild(desc_label_text);
    desc_div.appendChild(desc_label);
    desc_div.appendChild(desc_input);
    div.appendChild(desc_div);

    parent_div.appendChild(div);    
      
}


function drop_treat_input(dropbox_id){
  $(dropbox_id).parentNode.removeChild($(dropbox_id));  
}

var treatments = 1;

function add_treat_input(){

  //add your dropbox
  var dropbox = document.createElement('div'); 
  var dropbox_id = 'treat_'+treatments;

  dropbox.setAttribute('id', dropbox_id);
  dropbox.setAttribute('class', 'dropbox');

  var closebox = document.createElement('input');
  closebox.setAttribute('type', 'button')
  closebox.setAttribute('class', 'closebox');
  closebox.setAttribute('onClick', 'drop_treat_input("'+dropbox_id+'");');
  closebox.setAttribute('value', 'X');

  dropbox.appendChild(closebox);

  var dropboxtext1 = document.createElement('div');
  dropboxtext1.setAttribute('class', 'dropboxtext');
  var dropboxtext2 = document.createElement('div');
  dropboxtext2.setAttribute('class', 'dropboxtext');
  
  var label1 = document.createElement('label');
  label1.setAttribute('for', 'treat_'+treatments+'_name');
  var text1 = document.createTextNode('Name: '); 
  label1.appendChild(text1);
  
  var input1 = document.createElement('input');
  input1.setAttribute('type', 'text');
  input1.setAttribute('name', 'treat_'+treatments+'_name');
  input1.setAttribute('class', 'textinput');

  dropboxtext1.appendChild(label1);
  dropboxtext1.appendChild(input1);

  var label2 = document.createElement('label');
  label2.setAttribute('for', 'treat_'+treatments+'_desc');
  var text2 = document.createTextNode('Description');
  label2.appendChild(text2);
 
  var input2 = document.createElement('input');
  input2.setAttribute('type', 'text');
  input2.setAttribute('name', 'treat_'+treatments+'_desc');
  input2.setAttribute('class', 'textinput');
  
  dropboxtext2.appendChild(label2);
  dropboxtext2.appendChild(input2); 

  dropbox.appendChild(dropboxtext1);
  dropbox.appendChild(dropboxtext2);

  var dropbox_box = document.createElement('div');
  dropbox_box.setAttribute('id', 'treat_'+treatments+'_dropbox_box');
  dropbox_box.setAttribute('class', 'dropbox_box');  

  dropbox.appendChild(dropbox_box);

  $('treatments').appendChild(dropbox);  

  //make it droppable (can't pass treatments as arg cos is global)
  var div_id = "treat_"+treatments+"_dropbox_box";  
  var local_treat = treatments; 

  Droppables.add(div_id, {accept:'draggable_text', onDrop:function(element){
		     show_level(element,div_id);
	      	     store_treatment(element, local_treat);
		   } } ); 
 
  treatments++;
}

function show_level(element,div_id){
   $(div_id).innerHTML = $(div_id).innerHTML + '<br/><span class="droppedtext">'+element.innerHTML+'<span>';
}

function store_treatment(element,treat_num)
{
  var lvl_num = element.id.replace(/lvl_/,'');

  //store your hidden values inside the dropbox, so they get deleted if you delete the dropbox. 
  var dropbox_id = 'treat_'+ treat_num;
   var input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'treat_'+treat_num+'_lev_'+lvl_num);
  $(dropbox_id).appendChild(input);
  
  //$('stash').innerHTML = $('stash').innerHTML + new_content;
}

function store_channels(channel,treat_num, div_id)
{
 
  // alert("channel id=" + channel.id);
  //alert("treat num"  + treat_num);
  //alert("div id =" + div_id);

  var channel_num = channel.id.replace(/channel_/,'');
  
  //store your hidden values inside the dropbox
  //var dropbox_id = 'treat_'+ treat_num;
  var input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', div_id+'_channel_'+channel_num);
  $(div_id).appendChild(input);
 
}

