# ABSTRACT: 打包小说为TXT
=pod

=encoding utf8

=head1 FUNCTION

=head2 new 初始化

   my $packer = Novel::Robot::Packer::TXT->new({
	format_option => [ ], 
   });

=cut
package Novel::Robot::Packer::TXT;

use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Packer::Base';

use HTML::TreeBuilder;
use HTML::FormatText;
use IO::File;

sub BUILD {
    my ( $self ) = @_;
    $self->{formatter} = $self->{format_option} ?  HTML::FormatText->new(@{$self->{format_option}}) : HTML::FormatText->new() ;
    $self;
}

sub open_packer {
    my ($self, $index) = @_;
    my $fname = $self->format_filename("$index->{writer}-$index->{book}.txt");
    my $fh = IO::File->new($fname, '>:utf8');
}

sub format_before_index {
    my ( $self,$fh,  $index ) = @_;
    my $title = "$index->{writer}  《$index->{book}》 ";
    $fh->print("$title\n\n");
}

sub format_index {
    my ($self,$fh, $index) = @_;

    my $num = $index->{chapter_num};
    my $r = $index->{chapter_info};

    my @chap_list = map { "chap $_ ".($r->[$_-1]{title} || '') } (1 .. $num);
    my $toc = join("\n", @chap_list);

    $fh->print("$toc\n\n");
}

sub format_chapter {
    my ( $self, $fh, $chap, $id) = @_;
    $id ||= $chap->{id};

    my $tree = HTML::TreeBuilder->new_from_content("chap $id : $chap->{title}<br>$chap->{content}");
    my $c = $self->{formatter}->format($tree);

    $fh->print("$c\n\n");
} ## end sub generate_chapter_url

sub close_packer {
    my ($self,$fh, $index) = @_;
    $fh->close;
}

no Moo;
1;
