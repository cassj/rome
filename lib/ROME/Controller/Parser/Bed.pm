package ROME::Controller::Parser::Bed;

=head1 NAME

  ROME Parser for .bed (UCSC genome position format) files.

=head1 DESCRIPTION

  Genome position information is stored internally in ROME 
  as SQLite database files.

=head1 METHODS

=cut


use strict;
use warnings;
use base 'ROME::Controller::Parser';

use File::Find::Rule;



=head2 file_rule

  A File::Find::Rule to locate appropriate files in the upload directory.
  Just looks for the extension, doesn't do any magic. If it's not really a 
  .bed file, parse_files will complain.

=cut

__PACKAGE__->file_rule(File::Find::Rule->file->name( qr/\.BED/i ));


=head2 _parse_files

  The action which parsers these datafiles. 
  Templates and so on are set in ROME::Controller::Parser. 
  You can set stash->{error_msg} or ->{status_msg}
  if required, or you can throw an exception.

=cut

sub _parse_files : Local {
    my ($self, $c) = @_;

    # get an R processor
    my $R = $self->processor_factory($c, "R");

    #get your process (which should be added to the DB at install)
    my $process = $c->model('ROMEDB::Process')->find('parse_ucsc_bed');
    die "parse_ucsc_bed process not found in DB" unless $process;

    #set your R process.
    $R->process($process);

    #set the arguments for the process
    #note that the files must be the full paths to the files. 
    #the processor will do param checking on these, you don't have
    #to worry about it.
    my $filenames = $c->request->params->{selected_files};
    my @filenames = map {$c->user->upload_dir."/$_"} 
      ref($filenames) ? @{$filenames} : ($filenames);

    $R->arguments({
		     filenames   => \@filenames,
		     file_prefix => $c->request->params->{file_prefix},
		    });

    #create a job and put it in the job queue to be run
    $R->queue();

}



=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut




1;
