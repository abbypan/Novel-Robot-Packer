# ABSTRACT: 打包小说为HTML
package Novel::Robot::Packer::HTML;
use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Packer::Base';

use IO::File;

sub open_packer {
    my ($self, $index) = @_;

    $self->format_filename("$index->{writer}-$index->{book}.html");
    $self->{fh} = IO::File->new($self->{filename}, '>:utf8');
}

sub format_before_index {
    my ( $self, $index ) = @_;
    my $title      = "$index->{writer}  《$index->{book}》";
    my $css = $self->generate_css();
    my $index_url  = $index->{index_url} || '';
$self->{fh}->print(qq[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>

<head>
<title> $title </title>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<style type="text/css">
$css
</style>
</head>

<body>
<div id="title"><a href="$index_url">$title</a></div>

]);
}

sub generate_css
{
    my $css = <<__CSS__;
body {
	font-size: medium;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	margin: 1em 8em 1em 8em;
	text-indent: 2em;
	line-height: 145%;
}
#title, .fltitle {
	border-bottom: 0.2em solid #ee9b73;
	margin: 0.8em 0.2em 0.8em 0.2em;
	text-indent: 0em;
	font-size: x-large;
    font-weight: bold;
    padding-bottom: 0.25em;
}
#title, ol { line-height: 150%; }
#title { text-align: center; }
__CSS__
    return $css;
} ## end sub read_css
 
sub format_index {
    my ( $self, $index ) = @_;

    my $toc = '';
    for my $i ( 1 .. $index->{chapter_num} ) {
        my $u = $index->{chapter_info}[$i]{url};
        next unless ($u);

        my $t = $index->{chapter_info}[$i]{title} || '';
        $toc .= qq`<li><a href="#toc$i">$t</a></li>\n`;
    } ## end for my $i ( 1 .. $r->{chapter_num...})

    $toc = qq[<div id="toc"><ol>$toc</ol></div>] if($toc);
    $self->{fh}->print("$toc\n\n");

} ## end sub format_index

sub format_before_chapter {
    my ($self, $index) = @_;

    $self->{fh}->print('<div id="content">'."\n\n");
}


sub format_chapter {
    my ( $self, $chap , $id) = @_;

    $chap->{id} ||= $id || 1;
    my $j = sprintf( "%03d# ", $chap->{id});

    my $floor = <<__FLOOR__;
<div class="floor">
<div class="fltitle">$j<a name="toc$chap->{id}">$chap->{title}</a></div>
<div class="flcontent">$chap->{content}</div>
</div>
__FLOOR__

    $self->{fh}->print("$floor\n\n");
} ## end sub format_chapter

sub format_after_chapter {
    my ( $self, $index ) = @_;

    $self->{fh}->print("</div></body></html>");
}


sub close_packer {
    my ($self, $index) = @_;

    $self->{fh}->close;
}

no Moo;
1;
