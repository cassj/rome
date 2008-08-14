package ROME::View::DatafileGraph;

use strict;
use base 'Catalyst::View';
use GraphViz;

=head1 NAME

ROME::View::DatafileGraph - Catalyst GraphView View




=head1 SYNOPSIS

See L<ROME>

=head1 DESCRIPTION

Catalyst GraphView View to display the datafiles in an experiment


=head1 METHODS

=head2 process

Takes a ROMEDB::Experiment object (in $c->stash->{graphview}->{object}
and generates a GraphView object from its datafiles. Hands over to
ROME::View::GraphViz to render said object

=cut
sub process {
    my ($self, $c) = @_;

    my $expt = $c->stash->{graphview}->{object} or die ('No experiment specified in $c->stash->{graphview}->{object} for rendering');
    
    die "object should be a ROMEDB::Experiment not ".ref($expt) unless ref($expt) eq 'ROME::Model::ROMEDB::Experiment';

    my $expt_name = $c->user->experiment->name or die 'missing expt_name in cat context';
    my $expt_owner = $c->user->experiment->owner->username or die 'missing expt_owner in cat context';
    my $username = $c->user->username or die 'missing username in cat context';
    
    my $g = GraphViz->new(name  => "datafiles_img",
			  width => "10",
			  ratio => "compress",
			  overlap => "compress");

    #add a node for each datafile in this experiment
    foreach my $datafile ($c->user->experiment->datafiles){
      
      #is this datafile currently selected?
      my $is_selected = $c->model('ROMEDB::PersonDatafile')->find(
			      {
			       person => $c->user->username,
			       datafile_name => $datafile->name,
			       datafile_experiment_name => $datafile->experiment_name,
			       datafile_experiment_owner => $datafile->experiment_owner,
			      });
  
      my $name = $datafile->name;
      my $fill_colour = 'GhostWhite';
      $fill_colour = 'Gray' if $datafile->pending;
      $fill_colour = 'LemonChiffon' if $is_selected;
      my $font_colour = $datafile->pending ? 'Red' : 'Black';
      $g->add_node(name => $name,
		   URL =>  $c->uri_for('/datafile/select')."?experiment_name=$expt_name&experiment_owner=$expt_owner&datafile_name=$name",
		   shape => 'box',
		   fillcolor => $fill_colour,
		   style=>'filled',
		   fontname=>'arial',
		   fontsize=> '10',
		   fontcolor=> $font_colour,
	    );
      
    }

    #starting from the root datafiles, add edges where datafiles
    #are used as input or output to jobs.
    foreach my $root ($c->user->experiment->root_datafiles){
        $self->datafile_edges($g, $root);
    }

    
    
    #3. Forward to the GraphViz View
    $c->stash->{graphviz}->{graph} = $g;
    $c->forward('ROME::View::GraphViz');


    return 1;
}


sub datafile_edges{
    my ($self, $g, $datafile) = @_;
    
    #if this file is an input to any jobs, link it to 
    #the output 

    #these aren't jobs, they're datafiles?
    my @jobs = $datafile->input_to;
    foreach my $job (@jobs){

	my @out_datafiles = $job->out_datafiles;
	foreach my $out_datafile (@out_datafiles){
	    $g->add_edge($datafile->name => $out_datafile->name, label=>$job->process->name);
	    $self->datafile_edges($g,$out_datafile)
	}
    } 

}

=head1 AUTHOR

Caroline,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
