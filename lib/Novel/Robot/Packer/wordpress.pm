# ABSTRACT: 把小说发布到WordPress
=pod

=encoding utf8

=head1 FUNCTION

=head2 main

   my $index_url = $self->main($book_ref, 
        usr => 'someusr',
        passwd => 'somepasswd',,
        packer_url => 'http://www.somewordpress.com',
        tag => [ '定柔三迷', '古风' ], 
        category => [ '原创' ], 
   );

=cut

package Novel::Robot::Packer::wordpress;

use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Packer';

use XMLRPC::Lite;
use Encode;

sub main {
    my ($self, $book_ref, %o) = @_;

    my $post_chapter_sub = $self->post_chapter_sub(%o);

    my @chapter_url ;
    for my $c (@{$book_ref->{floor_list}}){
        my $d = $self->format_chapter($c);
        next unless($d);

        my $u = $post_chapter_sub->($d);

        push @chapter_url, 
            qq[<p><a href="$u">$c->{id} : $c->{title}</a></p>];

    }

    my $toc = join("\n", @chapter_url);

    my $index = {
        'title' => qq[$book_ref->{writer} 《$book_ref->{book}》 000 : 目录],
        'description' => qq[<p>来自：<a href="$book_ref->{book_url}">$book_ref->{book_url}</a></p>$toc],
        'mt_keywords' => [ $book_ref->{writer}, $book_ref->{book} ],
        'categories' => [], 
    };
    my $toc_url = $post_chapter_sub->($index);
    return $toc_url;
}

sub format_chapter {
    my ( $self, $c) = @_;
    return unless($c and $c->{content});

    my $j = sprintf("%03d", $c->{id});

    my $d = {
        'title' => qq[$c->{writer} 《$c->{book}》 $j : $c->{title}],
        'description' => qq[<p>来自：<a href="$c->{url}">$c->{url}</a></p><br/>$c->{content}],
        'mt_keywords' => [ $c->{writer}, $c->{book} ],
        'categories' => [], 
    };

    return $d;
} ## end sub generate_chapter_url

sub post_chapter_sub {
    my ($self, %o) = @_;
    $o{tag} ||= [];
    $o{category} ||= [];
    $o{packer_url}=~s#/$##;

    my $wp = XMLRPC::Lite->proxy("$o{packer_url}/xmlrpc.php");
    
    my $write_sub = sub {
        my ($d) = @_;

        push @{$d->{mt_keywords}}, @{$o{tag}};
        $d->{mt_keywords} = join(", ", @{$d->{mt_keywords}});

        my @fields = qw/title description mt_keywords/;
        $d->{$_} = encode('utf8', $d->{$_}) for @fields;

        push @{$d->{categories}}, @{$o{category}};
        $_ = encode('utf8', $_) for @{$d->{categories}};

        my $pid = 
        $wp->call('metaWeblog.newPost', 1, 
            $o{usr}, $o{passwd}, $d, 1 )->result;
        my $post_url = "$o{packer_url}/?p=$pid";

        return $post_url;
    };

    return $write_sub;
}

1;
