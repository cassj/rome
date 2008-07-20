package ROME::Controller::Parser;

use strict;
use warnings;

#is this really necessary?
use base 'ROME::Controller::Base';

use Class::Data::Inheritable;
use File::Find::Rule;
use Module::Find;
use Path::Class;

=head1 NAME

ROME::Controller::Parser 

=head1 DESCRIPTION

Base class for ROME data parsers.

=head1 METHODS

=over 2

=cut

 __PACKAGE__->mk_classdata('file_rule');
 __PACKAGE__->file_rule(File::Find::Rule->file);


=item valid_files

  returns a reference to an array of all the uploaded files valid
  for this parser, as defined by __PACKAGE__->file_rule.

=cut

sub valid_files : Local {
    my ($self, $c) = @_;
    my $rule = $self->file_rule;
    my $upload_dir = dir($c->config->{userdata},$c->user->username,'uploads');
    my @files = $rule->relative->in("$upload_dir");
    return \@files;
}



=item parse
  
  Global action. Matches /parse

  Checks what parsers are installed available and returns the
  parser form.

=cut

sub parse : Global {
    my ($self, $c) = @_;

    $c->stash->{template} = 'parser/form';

   #submitted?
   $c->forward('parse_files') if $c->request->params->{selected_files};

    #check we've got an experiment selected.
    if ($c->user->experiment){
      my @parsers = map {/ROME::Controller::Parser::(.+)/} 
	  findsubmod ROME::Controller::Parser;
      $c->stash->{parser_list} = \@parsers;
    }
}



=item set_parser

  Global ajax method called when the select_parser form (in parser/form) is submitted.
  

=cut

sub set_parser : Global {
    my ($self, $c) = @_;

    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'parser/select_files';

    unless ($c->request->params->{selected_parser}){
      $c->session->{parser} = '';
      $c->stash->{error_msg} = "Please select a parser";
      return;
    }

    #parsers we've got: 
    my %parsers = map {/ROME::Controller::Parser::(.+)/ => 1} findsubmod ROME::Controller::Parser;
    
    #have we got the selected parser?
    my $parser;
    unless($parsers{$c->request->params->{selected_parser}}){
      $c->stash->{error_msg} = "The selected parser isn't found";
      return;
    }
    
    #ok, store this parser for later (need to lc for url).
    $c->session->{parser} = lc($c->request->params->{selected_parser});

    # and call it's valid_files action 
    # which it inherits from here, but defines its own File::Find::Rule)
    # to get the list of files it can process. 
    my $files = $c->forward('/parser/'.lc($c->request->params->{selected_parser}).'/valid_files');

    unless ($files){
      $self->stash->{error_msg} = "That parser can't find any suitable files in your upload directory";
      return;
    }
    
   $c->stash->{uploaded_file_list} = [sort {$a cmp $b } @$files];
  
  }



=item parse_files

  Checks the files are valid and calls the subclass _parse_files method
  to do the parsing.

=cut
sub parse_files : Local {
    my ($self,$c)  = @_;

    my $files = $c->request->params->{selected_files};

    #if a single file is selected, this is a scalar, not arrayref
    my @files = ref($files) ? @$files : ($files);


    #quick sanity check on the specified files.
    foreach (@files){
      $c->stash->{error_msg} = "Disallowed filename: $_, please change and resubmit" unless /^[\w\/]+\.?[\w]*$/;

      my $file = file($c->config->{userdata},$c->user->username, 'uploads',$_);
      $c->stash->{error_msg} = "File $_ doesn't exist" unless (-e "$file");
      $c->stash->{error_msg} = "File $_ is not readable" unless (-r "$file");
      return if $c->stash->{error_msg};
    }

    #parse your data. undef if it fails so just return
    $c->forward(lc('/parser/'.$c->session->{parser}).'/_parse_files') or return;

#    $c->stash->{status_msg} = 'something other than the default if you like';

}


sub _validate_params : Local{
  my ($self, $c) = @_;
  
  my $upload_dir = dir($c->config->{userdata},$c->user->username,'uploads');

     my $dfv_profile = {
 	msgs => {
	    constraints => {
		  'disallowed_chars' => "Disallowed characters in filename. Please check.",
                  'nonexistent' => "File does not exist",
                  'notreadable' => "Can't read file", 
	    },
	    format => '%s',
	},
        required => [qw(selected_files)],
        filters => ['trim'],
        missing_optional_valid => 1,    
        constraint_methods => {
			      selected_files => [
						 {
						  constraint => sub {
						    my $dfv = shift;
						    my $files = $dfv->get_current_constraint_value();
						    $dfv->name_this('nonexistent');
						    foreach (@$files){
						      my $file = file($upload_dir,$_);
						      return (-e "$upload_dir/$_");
						    };
						  },
						 },
						 {
						  constraint => sub {
						    my $dfv = shift;
						    my $files = $dfv->get_current_constraint_value();
						    my $upload_dir = $c->user->upload_dir;
						    $dfv->name_this('notreadable');
						    foreach (@$files){
						      my $file = file($upload_dir,$_);
						      return (-r "$upload_dir/$_");
						    };
						  },
						 },
						 {
						  constraint => sub {
						    my $dfv = shift;
						    my $files = $dfv->get_current_constraint_value();
						    $dfv->name_this('disallowed_chars');
						    foreach (@$files){return  $_ =~/^[\d\w]+$/ ? 1 : 0;}
						 },
					       }
			      ],
		       },
		     };


    $c->form($dfv_profile);  
}


=back

=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
