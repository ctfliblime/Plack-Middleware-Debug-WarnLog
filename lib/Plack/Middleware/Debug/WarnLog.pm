package Plack::Middleware::Debug::WarnLog;
use parent qw(Plack::Middleware::Debug::Base);

# ABSTRACT: Log warnings into the Plack debug panel

use strict;
use warnings;

our $VERSION = '0.001';

use constant warn_key => 'plack.middleware.debug.warnlog';

sub call {
    my ($self, $env) = @_;

    my $old_warn = $SIG{__WARN__} || sub { warn @_ };
    local $SIG{__WARN__} = sub {
        push @{$env->{&warn_key}}, @_;
        $old_warn->(@_);
    };

    $self->SUPER::call($env);
}

sub run {
    my($self, $env, $panel) = @_;

    return sub{
        my $res = shift;

        $env->{&warn_key} ||= [];

        my $plural = (@{$env->{&warn_key}} != 1) ? 's' : '';
        my $count = scalar @{$env->{&warn_key}} || 'No';
        my $subtitle = sprintf('%s warning%s', $count, $plural);

        $panel->nav_title('Warnings');
        $panel->nav_subtitle($subtitle);
        $panel->content($self->render_lines($env->{&warn_key}));

        # Just so it doesn't also show up in the 'Environment' panel
        delete $env->{&warn_key};
    };
}

1;

__END__

=head1 NAME

Plack::Middleware::Debug::WarnLog

=head1 SYNOPSIS

  # app.psgi
  builder {
      enable 'Debug', panels => ['WarnLog'];
      $my_app;
  };

=head1 DESCRIPTION

Plack::Middleware::Debug::WarnLog logs warnings into the Plack debug panel.

=head1 AUTHOR

Clay Fouts E<lt>cfouts@khephera.netE<gt> (original author)

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Plack::Middleware::Test::StashWarnings>

=cut
