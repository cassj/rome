package ROME::Controller::Parser::Fasta;

use strict;
use warnings;
use base 'ROME::Controller::Parser';
use ROME::Processor;
use File::Find::Rule;
use Path::Class;

our $VERSION = '0.0.1';

=head1 NAME

ROME::Controller::Parser::Fasta

=head1 DESCRIPTION

Subclass of ROME::Controller::Parser to parse Fasta files.
Actually, doesn't do much in the way of parsing - will concatenate
multiple selected files, but otherwise just makes the fasta file into
ROME datafiles. Adds the individual sequences as experimental outcomes.


=head1 METHODS

=cut


=head2 file_rule

  A File::Find::Rule to locate appropriate files in the upload directory.

=cut

__PACKAGE__->file_rule(File::Find::Rule->file->name( qr/\.fa(sta)?$/i ));


=head2 _parse_files

  Parses the fasta files. Actually, just concatenates the files if there
  are multiple, adds each of the sequences as an experimental outcome
  and adds the file as a root datafile

=cut

sub _parse_files : Local {
    my ($self, $c) = @_;

    #everything except the process is generic. Have a ->_process sub and 
    #shift everything else to base.
    
    #get your process (which should be added to the DB at install)
    my $process = $c->model('ROMEDB::Process')->find
	({
	  name => 'parse_fasta',
	  component_name =>'parse_fasta',
	  component_version => __PACKAGE__->VERSION,
	});
    die "parse_fasta process not found in DB" unless $process;

    #get a processor
    my $processor = ROME::Processor->new($process->processor);

    #set your process.
    $processor->process($process);

    #set the arguments for the process
    #Base parser checks these for you. 
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
