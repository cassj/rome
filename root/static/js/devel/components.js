
function upload_template (){

    //submit the form
    $('process_template_upload_form').request(({ method: 'post', enctype:'multipart/form-data'}));

    //tell the user you've done so
    $('template_upload_results').innerHTML='<span class="message">Template Updated</span>';

}
