# ABSTRACT: 打包小说为TXT
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
    $self->format_filename("$index->{writer}-$index->{book}.txt");
    $self->{fh} = IO::File->new($self->{filename}, '>:utf8');
}

sub format_before_index {
    my ( $self, $index ) = @_;
    my $title = "$index->{writer}  《$index->{book}》 ";
    $self->{fh}->print("$title\n\n");
}

sub format_index {
    my ($self, $index) = @_;

    my $num = $index->{chapter_num};
    my $r = $index->{chapter_urls};

    my @chap_list = map { "chap $_ ".($r->[$_] || '') } (1 .. $num);
    my $toc = join("\n", @chap_list);

    $self->{fh}->print("$toc\n\n");
}

sub format_chapter {
    my ( $self, $chap, $id) = @_;

    $id ||= $chap->{id};
    my $tree = HTML::TreeBuilder->new_from_content("chap $id<br>$chap->{content}");
    my $c = $self->{formatter}->format($tree);

    $self->{fh}->print("$c\n\n");
} ## end sub generate_chapter_url

sub close_packer {
    my ($self, $index) = @_;
    $self->{fh}->close;
}

no Moo;
1;
