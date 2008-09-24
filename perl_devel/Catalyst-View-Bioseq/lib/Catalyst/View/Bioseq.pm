package Catalyst::View::Bioseq;

use strict;
use base qw/Catalyst::View/;
use Bio::Seq;
use Bio::Graphics::Panel;

our $VERSION = '0.27';

=head1 NAME

Catalyst::View::Bioseq - Bioperl Bio::Seq View Class

=head1 SYNOPSIS

# use the helper to create your View
    myapp_create.pl view Bioseq Bioseq

# render view from lib/MyApp.pm or lib/MyApp::C::SomeController.pm

    sub message : Global {
        my ( $self, $c ) = @_;
        $c->stash->{bioseqview}->{seq} = $bioseq;
        $c->forward('MyApp::View::Bioseq');
    }

=cut


sub process {
    my ( $self, $c ) = @_;

    my $seq = $c->stash->{seq};

    unless (defined $seq) {
        $c->log->debug('No Bio::Seq specified for rendering') if $c->debug;
        return 0;
    }

    my $output = $self->render($c, $seq);

    unless ($output){
      my $error = q/Couldn't generate Sequence image/;
      $c->log->error($error);
      $c->error($error);
      return 0;
    }

    #should this be an image type?
    unless ( $c->response->content_type ) {
      my $type = $c->stash->{bioseqview}->{type} || 'png';
      $c->response->content_type("image/$type");
#        $c->response->content_type('text/html; charset=utf-8');
    }

    $c->response->body($output);

    return 1;
}


sub render {
  my ($c, $seq, $args ) = @_;

  my $output = 'This would be some output';

  return $output;
}

1;

__END__

=head1 DESCRIPTION

This is the Catalyst view class for Bioperl L<Bio::Seq> objects.
Your application should defined a view class which is a subclass of
this module.  The easiest way to achieve this is using the
F<myapp_create.pl> script (where F<myapp> should be replaced with
whatever your application is called).  This script is created as part
of the Catalyst setup.

    $ script/myapp_create.pl view Bioseq Bioseq

This creates a MyApp::View::Bioseq.pm module in the F<lib> directory (again,
replacing C<MyApp> with the name of your application) which looks
something like this:

    package FooBar::View::Bioseq;
    
    use strict;
     use base 'Catalyst::View::Bioseq';

    __PACKAGE__->config->{DEBUG} = 'all';

Now you can modify your action handlers in the main application and/or
controllers to forward to your view class.  You might choose to do this
in the end() method, for example, to automatically forward all actions
which have $c->stash->{bioseqview}->{seq} defined to this view

# In MyApp::Controller::Root

  if($c->stash->{bioseqview}->{seq}){
      my $view = $c->stash->{bioseqview}->{view} || 'MyApp::View::Bioseq';
      $c->forward($view);
  } 



By default, output is PNG. You can, in theory, select anything that GD can handle, but
I haven't tested it for anything other than PNG yet. Output type can be specified in 
$c->stash->{bioseqview}->{type}


=head2 METHODS

=head2 new

The constructor for the TT view. Sets up the template provider, 
and reads the application config.

=head2 process

Renders the template specified in C<< $c->stash->{template} >> or
C<< $c->action >> (the private name of the matched action.  Calls L<render> to
perform actual rendering. Output is stored in C<< $c->response->body >>.


=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Helper::View::Bioseq>,
L<Bio::Seq>, L<Bio::Graphics>

=head1 AUTHORS

Caroline Johnston, C<johnston@biochem.ucl.ac.uk>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut
