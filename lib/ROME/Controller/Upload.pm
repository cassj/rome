package ROME::Controller::Upload;

use strict;
#use base 'Catalyst::Base';
use base 'ROME::Controller::Base';
use Data::Dumper;

use Cwd;
use File::Find::Rule;
use File::MMagic;



#what the hell is the point of this?

=head2 index

  maps to /upload
  forwards to /upload/upload

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    
    $c->forward( 'upload' );
}


=head2 upload

  If there's an uploaded file in the request, this method processes it
  Returns the upload form.

=cut

sub upload : Local {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'upload/upload';

    return unless my $upload = $c->request->uploads->{upload_file};

    #check permissions.
    my $user = $c->user;
    if ($c->request->params->{person}){
      unless($c->check_user_roles('admin')){
	$c->stash->{error_msg} = "You don't have permission to upload files for other users.";
	return;
      }
      $user = $c->request->params->{person};
    }
    
    my $subdir = $c->request->params->{subdir};
    $subdir =~s/[^\w\d]//g;

    my $path = $user->upload_dir.'/';
    
    if($subdir){
      mkdir("$path/$subdir");
      $path = "$path/$subdir/";
    }
    
    #check it doesn't already exist
    if (-e $path.$upload->filename){
      $c->stash->{error_msg} = 'Sorry, that file already exists.';
      return;
    }

    #store the file,
    $upload->copy_to($path.$upload->filename);

    #unpack it ?
    $self->_unpack($path.$upload->filename);
#    my @new_files = @{$self->_unpack($path.$upload->filename)};
#    @new_files = map {/^.*\/(.+)$/} @new_files;

    my $msg = 'File '. $upload->{filename}.' successfully uploaded and unpacked.';


#      if (scalar(@new_files)>1){
#	$msg.= '<br/>Unpacked files: ';
#	$msg.= join (', ', @new_files);
#      }

    #success!
    $c->stash->{status_msg} = $msg;
}



#this just unpacks the given file.
sub _unpack {
   my ($self, $path) = @_;

   die "File doesn't exist" unless -e $path;

   #can we get an unpack cmd based on the filename 
   my $cmd = $self->_get_unpack_cmd("$path");
   
   #no?
   unless ($cmd){
    #store file as is, but warn
    warn "No unpack method for file:\n\t $path, \n\tleaving as it is\n";
    return [$path];
   }

   #ok, go ahead and unpack the file 
   my ($dir, $file) = $path =~ /(.*)\/(.*)\/?/;
   my $cwd = getcwd(); 
   chdir($dir);
   system("$cmd $file"); 
   chdir($cwd);

   #and ditch the original file
   unlink $path;   
   
   return 1;
#   #return all the files you've just created.
#   my @files = File::Find::Rule->file->modified->in("$dir");
#   return \@files;
}


sub _get_unpack_cmd(){
   my ($self, $file) = @_;

   die 'no file given' unless $file;

   #get the file's MIME type:
   my $mm = File::MMagic->new();
   my $mime = $mm->checktype_filename("$file");
   my $cmd = "";

   $_ = $mime;
   warn "I think $file is a $mime";
   SWITCH: {
       /application\/x-gtar/ && do {
          $cmd = "tar -xf ";
	  last SWITCH;
       };

       /application\/x-gzip/ && do {
         if ($file =~ /tgz|tar.gz/) {
	  $cmd = "tar -xzf " ;
	 }
	 else{
	  $cmd = "gunzip -f ";
	 }
	  last SWITCH;
       };

       /application\/x-bzip/ && do {
         if ($file =~ /tbz|tar.bz|tbz2|tar.bz2/) {
           $cmd = "tar -xjf ";
	 }
	 else{
	   $cmd = "bunzip2 -f ";
	 }
	  last SWITCH;
       };

       /application\/x-zip/ && do{
         if ($file =~ /tZ|tar.Z/) {
           $cmd = "tar -xZf ";
	 }
	 else {
	   $cmd = "unzip ";
	 }
	  last SWITCH;
       };

   };

    return ($cmd);

}



=head2 autocomplete_subdir

  returns a list of subdirectories in the upload dir,
  formated for the autocompleter, from which the user
  can select.

=cut

sub autocomplete_subdir : Local{
  my ($self, $c, $user) = @_;

  #grab the typed value
  my $val = $c->request->params->{subdir};
  $val =~ s/\*/%/;
  $c->stash->{ajax} = 1;

  #return nothing if you don't have permissions.
  if ($user){
    return unless $c->check_user_roles('admin');
  }
  else{
    $user = $c->user;
  }

  opendir DIR, $user->upload_dir;
  my @subdirs = grep {/.*$val.*/}
                  grep {!/^\.+$/ && -d $user->upload_dir.'/'.$_} 
		    readdir(DIR);
  closedir DIR;
  

  $c->stash->{template}='upload/autocomplete_subdirs';
  $c->stash->{subdirs}=\@subdirs;
}

=head2 list

  returns a list of the contents of the user's upload directory with delete links

=cut



sub list :Local{
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'upload/list';
  
}


=head2 delete 

  deletes files from the upload directory

=cut
###TODO: This doesn't work with nested dirs more than 1 level below uploads.
sub delete :Local{
  my ($self, $c, $subdir, $file) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'upload/list';
 
  $subdir = $c->request->params->{subdir} unless $subdir;
  $file = $c->request->params->{file} unless $file;


  #if we haven't got either, don't try and delete the upload dir!
  unless ($subdir || $file){
    $c->stash->{error_msg} = "You haven't specified a file or a subdirectory";
    return;
  }
  #check your params don't contain anything nasty.
  if ($subdir){
    $subdir =~ s/\///g if $subdir;
    unless ($subdir =~/\w/){
      $c->stash->{error_msg} = "Invalid characters in directory name";
      return;
    }
  }
  if($file){
    unless ($file =~ /[\w-]+\.?[\w]?/){
      $c->stash->{error_msg} = "Invalid characters in file name";
      return;
    }
  }

  #does this dir / file exist in the user's upload dir? 
  my $path = $c->user->upload_dir;
  $path .= "/$subdir" if $subdir;
  $path .= "/$file" if $file;

  unless (-e $path){
    $c->stash->{error_msg} = "The file you are trying to delete isn't found.";
    return;
  }

  #how dangerous is this? the path is from the DB and is not created by the user.
  system("rm -Rf $path");

  #ditch the directory if it's empty
  if ($subdir){
    rmdir $c->user->upload_dir."/$subdir";
  }

  my $msg = "deleted: ";
  $msg .= "$subdir/" if $subdir;
  $msg .= $file if $file;
  $c->stash->{status_msg} = $msg;

}

1;
