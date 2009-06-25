package Text::MicroTemplate::Extended;
use strict;
use warnings;
use base 'Text::MicroTemplate::File';

our $VERSION = '0.01';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{template_args} ||= {};
    $self->{extension}     ||= '.mt';

    eval <<"...";
package $self->{package_name};

sub context {
    no warnings;
    \$self->{render_context};
}

sub extends {
    my \$template = shift;
    context->{extends} = \$template;
}

sub block {
    my (\$name, \$code) = \@_;

    my \$block = context->{blocks}{\$name} ||= {
        context_ref => \$$self->{package_name}::_MTREF,
        code        => \$code,
    };

    my \$current_ref = \$$self->{package_name}::_MTREF;
    my \$block_ref   = \$block->{context_ref};

    my \$rendered = \$\$current_ref;
    \$\$block_ref = '';

    my \$result = \$block->{code}->();

    \$\$current_ref = (\$rendered || '') . (\$result || '');
}
...

    $self;
}

sub template_args {
    my $self = shift;
    $self->{template_args} = $_[0] if @_;
    $self->{template_args};
}

sub extension {
    my $self = shift;
    $self->{extension} = $_[0] if @_;
    $self->{extension};
}

sub render {
    my ($self, $template) = @_;

    my $context = $self->render_context || {};
    $self->render_context($context);

    my $renderer = $self->build_file( $template . $self->extension );
    my $result   = $renderer->(@_)->as_string;

    if (my $parent = delete $context->{extends}) {
        $result = $self->render($parent);
    }

    $self->render_context(undef);

    $result;
}

sub render_context {
    my $self = shift;
    $self->{render_context} = $_[0] if @_;
    $self->{render_context};
}

sub build {
    my $self = shift;

    my $context = $self->render_context;
    $context->{code}   = $self->code;
    $context->{caller} = sub {
        my $i = 0;
        while (my @c = caller(++$i)) {
            return "$c[1] at line $c[2]" if $c[0] ne __PACKAGE__;
        }
        '';
    }->();

    $context->{args} = '';
    for my $key (keys %{ $self->template_args || {} }) {
        unless ($key =~ /^[a-zA-Z_][a-zA-Z0-9_]*$/) {
            die qq{Invalid template args key name: "$key"};
        }
        $context->{args} .= qq{my \$$key = \$self->template_args->{$key};\n};
    }

    $context->{blocks} ||= {};

    my $die_msg;
    {
        local $@;
        if (my $builder = $self->eval_builder) {
            return $builder;
        }
        $die_msg = $self->_error($@, 4, $context->{caller});
    }
    die $die_msg;
}

sub eval_builder {
    my $self = shift;

    local $SIG{__WARN__} = sub {
        print STDERR $self->_error(shift, 4, $self->render_context->{caller});
    };

    eval <<"...";
package $self->{package_name};
sub {
    $self->{render_context}{args};
    Text::MicroTemplate::encoded_string(($self->{render_context}{code})->(\@_));
}
...
}

=head1 NAME

Text::MicroTemplate::Extended - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

  use Text::MicroTemplate::Extended;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009 by KAYAC Inc.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
