package ROME::Controller::RMA;

use strict;
use warnings;
use base 'ROME::Controller::Base';

=head1 NAME

ROME::Controller::RMA

=head1 DESCRIPTION

ROME Controller class for RMA Component

Performs RMA normalisation to generate an ExpressionSet datafile.

=head1 METHODS

=cut


=head2 index

  Returns the main RMA page.

=cut

sub index : Local{
    my ($self,$c) = @_;
 
    # check if this component is currently active, if not
    # return a message 
#    $c->forward('check_valid_datafiles');

    $c->stash->{template} = "rma/form.tt2";
}










sub _validate_params : Local{
  my ($self, $c) = @_;
  
     my $dfv_profile = {
 	msgs => {
	    constraints => {
		  'disallowed_chars' => "Disallowed characters in filename. Please check.",
                  'nonexistant' => "File does not exist",
                  'notwritable' => "Can't read file", 
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
						    my $upload_dir = $c->user->upload_dir;
                                                    use Data::Dumper;
						    die Dumper($files);
						    $dfv->name_this('nonexistant');
						    foreach (@$files){return (-e "$upload_dir/$_")};
						  },
						 },
						 {
						  constraint => sub {
						    my $dfv = shift;
						    my $files = $dfv->get_current_constraint_value();
						    my $upload_dir = $c->user->upload_dir;
						    $dfv->name_this('notwritable');
						    foreach (@$files){return (-r "$upload_dir/$_")};
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




=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
