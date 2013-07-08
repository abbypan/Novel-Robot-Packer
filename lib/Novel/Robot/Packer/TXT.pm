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

has '+suffix'    => ( default => sub {'txt'} );


sub BUILD {
    my ( $self ) = @_;
    $self->{formatter} = $self->{format_option} ?  
    HTML::FormatText->new(@{$self->{format_option}}) : 
    HTML::FormatText->new() ;
    $self;
}

sub format_before_index {
    my ( $self,$index ) = @_;
    my $title = "$index->{writer}  《$index->{book}》 ";
    return $title;
}

sub format_index {
    my ($self,$index) = @_;

    my $num = $index->{chapter_num};
    my $r = $index->{chapter_info};

    my @chap_list = map { "chap $_ ".($r->[$_-1]{title} || '') } (1 .. $num);
    my $toc = join("\n", @chap_list);

    return $toc;
}

sub format_chapter {
    my ( $self, $chap, $id) = @_;
    $id ||= $chap->{id};

    my $tree = HTML::TreeBuilder->new_from_content("chap $id : $chap->{title}<br>$chap->{content}");
    my $c = $self->{formatter}->format($tree);

    return $c;
} ## end sub generate_chapter_url

no Moo;
1;
