#===============================================================================
#
#  DESCRIPTION:  Test Slide formatter
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

package T::Slide;
use TBase;
use base 'TBase';
use strict;
use warnings;
use Test::More;

sub t_DESCRIPTION : Test {
    my $t = shift;
    my $y = $t->get_out4block('DESCRIPTION', <<TXT);
=for DESCRIPTION
= :title<Title> :pubdate('15.04.2010')
= :author('Aliaksandr')
TXT
is $y,
'\title{Title}
\author{Aliaksandr}
\date{15.04.2010}';
}

sub t_SLIDE : Test {
    my $t = shift;
    my $x = $t->get_out4block('Slide', <<TXT);
=begin Slide :title("Test title")
Test text B<wetwetwe>
=end Slide
TXT
is $x, '\begin{frame}
\frametitle{Test title}
Test text \textbf{wetwetwe}

\end{frame}'
}

sub t_03_doc : Test {
    my $t = shift;
    my $x = $t->get_out4block('item',<<TXT);
=for item :term<Term>
Test term
TXT
    diag $x;
}
1;


