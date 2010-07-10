#===============================================================================
#
#  DESCRIPTION:  Make presentations
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::Slide;
use Perl6::Pod::To;
use Perl6::Pod::Parser::ListLevels;
use base 'Perl6::Pod::To';
use strict;
use warnings;
use XML::ExtOn('create_pipe');
use Data::Dumper;
$Perl6::Pod:::Slide:VERSION = '0.01';

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    return create_pipe( 'Perl6::Pod::Parser::ListLevels', $self );
}

sub on_start_document {
    my $self = shift;
    $self->print_export(<<'HEAD');
% maked by p5-Perl6-Pod-Slide
%
\documentclass{beamer}
\useinnertheme{umbcboxes}
\setbeamercolor{umbcboxes}{bg=violet!12,fg=black}

\usetheme{umbc4}
\setbeamertemplate{blocks}[rounded][shadow=true] 
\useoutertheme[footline=authortitle]{miniframes}
\usetheme[height=7mm]{Rochester}
%\useoutertheme{umbcfootline} 
\usepackage{listings}

\usepackage[T2A]{fontenc}
\usepackage[utf8]{inputenc}
\setbeamertemplate{items}[ball] 
\setbeamertemplate{navigation symbols}{} 

% insert for eps
\ifx\pdftexversion\undefined
\usepackage[dvips]{graphicx}
\else
\usepackage{graphicx}
\DeclareGraphicsRule{*}{mps}{*}{}
\fi


% Permet l'ajout de code par insertion du fichier le contenant
% Coloration + ajout titre
% Les arguments sont :
% $1 : titre associИ Ю l'extrait de code
% $2 : nom du fichier Ю inclure
% $3 : le type de langage (C++, C, Java ...)
\newcommand{\addCode}[2]{%

  % Configuration de la coloration syntaxique du code
  \definecolor{colKeys}{rgb}{0,0,1}
  \definecolor{colIdentifier}{rgb}{0,0,0}
  \definecolor{colComments}{rgb}{0,0.5,1}
  \definecolor{colString}{rgb}{0.6,0.1,0.1}

  % Configuration des options
  \lstset{%
    language = #2,%
    identifierstyle=\color{colIdentifier},%
    basicstyle=\ttfamily\scriptsize, %
    keywordstyle=\color{colKeys},%
    stringstyle=\color{colString},%
    commentstyle=\color{colComments},%
    columns = flexible,%
    %tabsize = 8,%
    showspaces = false,%
    numbers = left, numberstyle=\tiny,%
    frame = single,frameround=tttt,%
    breaklines = true, breakautoindent = true,%
    captionpos = b,%
    xrightmargin=10mm, xleftmargin = 15mm, framexleftmargin = 7mm,%
  }%
    \begin{center}
    \lstinputlisting{#1}
    \end{center}
}

HEAD
    return $self->SUPER::on_start_document();
}

sub out_parser { $_[0]->{out_put} }

sub print_export {
    my $self = shift;
    push @_, "\n";
    return $self->SUPER::print_export(@_);
}

sub export_block_Pause {
    my $self = shift;
    my $el   = shift;
    return join "\n", ( '\pause', @_ );
}

sub export_block_Latex {
    my $self = shift;
    my $el   = shift;
    return join "\n" => @_;
}

sub export_block_code {
    my $self  =shift;
    my $el = shift;
    return join "\n",'\begin{verbatim}',@_,
    '\end{verbatim}'
}

sub export_block_Slide {
    my $self = shift;
    my $el   = shift;

    #check if open doc frame
    unless ( $self->{START_DOC}++ ) {
        $self->print_export(<<'SL');
\begin{document}
%--- the titlepage frame -------------------------%
\begin{frame}[plain]
  \titlepage
\end{frame}
SL
    }
    my $pod_attr = $el->get_attr;
    my $outp     = $self->out_parser;
    my @res      = ("\\begin{frame}[fragile]");
    if ( my $title = $pod_attr->{title} ) {
        $title = join "" => @$title if ref($title);
        push @res, "\\frametitle{$title}";
    }
    push @res, @_, "\\end{frame}";
    return join "\n", @res;
    warn Dumper( [ map { "$_" } @res ] );
}

=head2 Image

\begin{figure}[h]
  \begin{center}
  \includegraphics[height=5cm,width=90mm]{leaves.jpg}
\end{center}
  \caption{Caption of the image}
\label{leave}
\end{figure}
            

=cut

sub export_block_Image {
    my $self      = shift;
    my $el        = shift;
    my $image     = shift;
    my $pod_attr  = $el->get_attr;
    my @size_attr = ();
    if ( my $height = $pod_attr->{height} ) {
        push @size_attr, "height=$height";
    }
    if ( my $width = $pod_attr->{width} ) {
        push @size_attr, "width=$width";
    }
    my $iattr = "";
    if (@size_attr) {
        $iattr = "[" . join( "=", @size_attr ) . "]";
    }
    #add $caption;
    my $ititle="";
    if ( my $title = $pod_attr->{title} ) {
        $ititle='\caption{'.$title.'}'
    }
    chomp $image;
    return '
\begin{figure}[!ht]
  \begin{center}
  \includegraphics' . $iattr . '{' . ${image} . '}
\end{center}'.$ititle.'
\label{leave}
\end{figure}
';

#    warn Dumper \@_;

}

sub export_code_B {
    my $self = shift;
    my $el   = shift;
    "\\textbf{@_}";
}

sub export_block_DESCRIPTION {
    my $self     = shift;
    my $el       = shift;
    my $pod_attr = $el->get_attr;
    my $outp     = $self->out_parser;
    my @res;
    my $title = $pod_attr->{title};
    if ( ref($title) ) {
        $title = join "" => @$title;
    }
    push @res, "\\title{$title}";
    my $author_txt =
      exists $pod_attr->{author}
      ? $pod_attr->{author}
      : "Unknown author. Use :author('My name')";
    push @res, "\\author{$author_txt}";

    my $pubdate =
      exists $pod_attr->{pubdate}
      ? $pod_attr->{pubdate}
      : '\today';
    push @res, "\\date{$pubdate}";
    return join "\n", @res;
}

=head2 Items


For make puse after item  add B<pause> attribute
    =for item :numbered :pause
    One
    =for item :numbered :pause
    Two

=cut

sub export_block_itemlist {
    my $self      = shift;
    my $el        = shift;
    my $list_type = {
        definition => 'description',
        unordered  => 'itemize',
        'ordered'  => 'enumerate'
    }->{ $el->attrs_by_name->{listtype} };
    join "\n", '
    \begin{' . $list_type . '}', @_, '\end{' . $list_type . '}';
}

sub export_block_item {
    my $self     = shift;
    my $el       = shift;
    my $item_def = '\item';
    if ( my $term = $el->get_attr->{term} ) {
        $term = join( "", @$term ) if ref($term) eq 'ARRAY';
        $item_def .= "[$term]";
    }
    if ( $el->get_attr->{pause} ) {
        push @_, '\pause';
    }
    join "\n", $item_def, @_;
}

sub end_document {
    my $self = shift;
    $self->print_export('\end{document}');
    return $self->SUPER::end_document;
}

1;

