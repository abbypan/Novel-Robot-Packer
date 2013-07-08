# ABSTRACT: 打包小说为HTML
package Novel::Robot::Packer::HTML;
use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Packer::Base';

use IO::File;

has '+suffix'    => ( default => sub {'html'} );

sub format_before_index {
    my ( $self,  $index ) = @_;
    my $title      = "$index->{writer}  《$index->{book}》";
    my $css = $self->generate_css();
    my $index_url  = $index->{index_url} || '';
return qq[
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

];
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
    my ( $self,  $index ) = @_;

    my $toc = '';
    for my $i ( 1 .. $index->{chapter_num} ) {
        my $r = $index->{chapter_info}[$i-1];
        my $u = $r->{url};
        next unless ($u);

        my $t = $r->{title} || '';
        my $j = sprintf("%03d", $i);
        $toc .= qq`<p>$j. <a href="#toc$i">$t</a></p>\n`;
    } ## end for my $i ( 1 .. $r->{chapter_num...})

    $toc = qq[<div id="toc">$toc</div>] if($toc);
    return $toc;

} ## end sub format_index

sub format_before_chapter {
    my ($self, $index) = @_;

    return '<div id="content">';
}


sub format_chapter {
    my ( $self, $chap , $id) = @_;


    $chap->{id} ||= $id || 1;
    my $j = sprintf( "%03d# ", $chap->{id});
    
    $chap->{title} ||= '[锁]';
    $chap->{content} ||='';

    my $floor = <<__FLOOR__;
<div class="floor">
<div class="fltitle">$j<a name="toc$chap->{id}">$chap->{title}</a></div>
<div class="flcontent">$chap->{content}</div>
</div>
__FLOOR__

    return $floor;
} ## end sub format_chapter

sub format_after_chapter {
    my ( $self,  $index ) = @_;

    return "</div></body></html>";
}



no Moo;
1;
