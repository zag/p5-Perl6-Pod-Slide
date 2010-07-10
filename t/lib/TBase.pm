#===============================================================================
#  DESCRIPTION:  Base class for tests
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
package TestSlide;
use warnings;
use strict;
use Perl6::Pod::Slide;
use base 'Perl6::Pod::Slide';
sub export_block_DESCRIPTION {
    my $self = shift;
    return $self->{DESCRIPTION} = $self->SUPER::export_block_DESCRIPTION(@_)
}

sub export_block_Slide {
    my $self = shift;
    return $self->{Slide} = $self->SUPER::export_block_Slide(@_)
}

1;
package TBase;
#Setup uses

use strict;
use warnings;
use Test::More;
use Test::Class;
use Perl6::Pod::Test;
use base qw( Test::Class Perl6::Pod::Test );
use Perl6::Pod::To::Mem;
use Perl6::Pod::To::XML;
use Perl6::Pod::To::DocBook;
use Perl6::Pod::To::XHTML;
use XML::Flow;
use XML::ExtOn ('create_pipe');

sub testing_class {
    my $test = shift;
    ( my $class = ref $test ) =~ s/^T[^:]*::/Perl6::Pod::/;
    return $class;
}

sub parse_to_latex {
  my $test  =shift;
  my ($text, @filters) = @_;
  my $out = '';
  my $to_mem = new TestSlide:: out_put => \$out;
  my ( $p, $f ) = $test->make_parser( @filters, $to_mem );
  $p->parse( \$text );
  return wantarray ? ( $p, $f, $out ) : $out;

}

=head2 get_out4block BLOCKNAME TEXT

return rendered out text
=cut

sub get_out4block {
    my $t = shift;
    my $blockname = shift;
    my  ( $p, $f, $out ) = $t->parse_to_latex(@_);
    return wantarray ? ($f, $f->{$blockname} ) : $f->{$blockname};
}

#overwrite Perl6::Pod::Test class
sub make_parser {
    my $self = shift;
    my ( $p, $out_formatter )  = $self->SUPER::make_parser(@_);
    #resgister
#    my $use = $p->current_context->use;
#    %$use = ( %$use, %{( NAME_BLOCKS )}); 
    return wantarray ? ( $p, $out_formatter ) : $p;

}

sub new_args { () }

sub _use : Test(startup=>1) {
    my $test = shift;
    use_ok $test->testing_class;
}


1;

