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
is $x, '\begin{frame}[fragile]
\frametitle{Test title}
Test text \textbf{wetwetwe}

\end{frame}'
}

sub t_03_code_lang : Test {
    my $t = shift;
    my $x = $t->parse_to_latex(<<'TXT');
=for code :lang('Perl')
  my $a;
TXT
    ok $x =~ /\\addCode{.*}{Perl}/g;
}
1;


