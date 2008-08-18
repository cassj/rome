package ROME::Controller::Parser;

use strict;
use warnings;

use base 'ROME::Controller::Base';
use ROME::Parser;
use Path::Class;


=head1 NAME

ROME::Controller::Parser 

=head1 DESCRIPTION

Base class for ROME data parsers.

=head1 METHODS

=over 2

=cut

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
      my @parsers = grep {!/^Base$/} ROME::Parser->subclasses;
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

    my $subclass = $c->request->params->{selected_parser} ;
    unless ($subclass){
      $c->session->{parser} = '';
      $c->stash->{error_msg} = "Please select a parser";
      return;
    }

    my $parser = ROME::Parser->new($subclass, $c);

    #ok, store the parser name for later
    $c->session->{parser} = $subclass;

    # and call it's valid_files action 
    my $files = $parser->valid_files;

    unless ($files){

      $c->stash->{error_msg} = "That parser can't find any suitable files in your upload directory";
      return;
    }
    
   $c->stash->{uploaded_file_list} = [sort {$a cmp $b } @$files];
  
  }



=item parse_files

  Checks the files are valid grabs the process and appropriate processor
  to do the parsing and parses the files.

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

    #retrieve the parser.
    my $parser = ROME::Parser->new($c->session->{parser} , $c);

    #get the process
    my $process = $parser->process($c);
    unless ($process){
      $c->log->error("Process not found for ".$c->session->{parser} );
      $c->stash->{error_msg} = "There seems to be a problem with this parser. Please contact your system administrator";
      return;
    }

    #get a processor
    my $processor = ROME::Processor->new($process->processor);

    # what the hell?
    # set your process in the processor
    $processor->process($process);
 
    # give the processor the current context
    $processor->context($c);

    #set the arguments for the process.
    my $filenames = $c->request->params->{selected_files};
    
    #make the filenames relative to the userdir
    my @filenames = map {''.file('uploads',$_)}
      ref($filenames) ? @{$filenames} : ($filenames);

    #These must have the same names as the arguments in the database for this process
    $processor->arguments({
		     filenames   => \@filenames,
		    });
    
    #need to put the context into the processor
    $processor->context($c);

    #create a job and put it in the job queue to be run
    return unless $processor->queue();

    #really shouldn't try to do this if the processor queue didn't work
    $c->stash->{status_msg} = 'Queued to be parsed';

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
