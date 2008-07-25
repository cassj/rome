package ROME::Controller::Parser::AffymetrixExpression;

use strict;
use warnings;
use base 'ROME::Controller::Parser';
use ROME::Processor;
use File::Find::Rule;
use Path::Class;

our $VERSION = '0.0.1';

=head1 NAME

ROME::Controller::Parser::AffymetrixExpression 

=head1 DESCRIPTION

Subclass of ROME::Controller::Parser to parse Affymetrix Expression 
data in the form of .CEL files.

=head1 METHODS

=cut


=head2 file_rule

  A File::Find::Rule to locate appropriate files in the upload directory.

=cut

__PACKAGE__->file_rule(File::Find::Rule->file->name( qr/\.CEL/i ));


=head2 _parse_files

  The action which parsers these datafiles. 
  Templates and so on are set in ROME::Controller::Parser. 
  You can set stash->{error_msg} or {status_msg}
  if required, or you can throw an exception.

=cut

sub _parse_files : Local {
    my ($self, $c) = @_;
    
    #get your process (which should be added to the DB at install)
    my $process = $c->model('ROMEDB::Process')->find
	({
	  name => 'parse_affy_expression',
	  component_name =>'parse_affy_expression',
	  component_version => __PACKAGE__->VERSION,
	});
    die "parse_affy_expression process not found in DB" unless $process;

    #get a processor
    my $processor = ROME::Processor->new($process->processor);


    #set your R process.
    $processor->process($process);

    #set the arguments for the process
    #note that the files must be the full paths to the files. 
    #the processor will do param checking on these, you don't have
    #to worry about it.
    my $filenames = $c->request->params->{selected_files};
    my @filenames = map {''.file($c->config->{userdata},$c->user->username, 'uploads',$_)}
      ref($filenames) ? @{$filenames} : ($filenames);

    #These must have the same names as the arguments in the database for this process
    $processor->arguments({
		     filenames   => \@filenames,
		    });


    #need to put the context into the processor
    $processor->context($c);

    #create a job and put it in the job queue to be run
    $processor->queue();

}



=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
