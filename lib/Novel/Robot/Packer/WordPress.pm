# ABSTRACT: 把小说发布到WordPress
=pod

=encoding utf8

=head1 FUNCTION

=head2 open_packer 

   my ($write_sub, $write_dst) = $self->open_packer($index_ref, {
        username => 'someusr',
        password => 'somepasswd',,
        base_url => 'http://www.somewordpress.com',
        tag => [ '定柔三迷', '古风' ], 
        category => [ '原创' ], 
   });

=cut
package Novel::Robot::Packer::WordPress;

use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Packer::Base';

use WordPress::XMLRPC;
use Encode;
use Encode::Locale;


sub open_packer {
    my ($self, $index_ref, $o) = @_;
    $o->{tag} ||= [];
    $o->{category} ||= [];

    $o->{base_url}=~s#/$##;
    
    my $wp = WordPress::XMLRPC->new( {   
            username => $o->{usr},
            password => $o->{passwd},
            proxy    => "$o->{base_url}/xmlrpc.php",
        });


    my $write_sub = sub {
        my ($d) = @_;
        push @{$d->{mt_keywords}}, @{$o->{tag}} ;
        $d->{mt_keywords} = join(", ", @{$d->{mt_keywords}});

        my @fields = qw/title description mt_keywords/;
        $d->{$_} = encode('utf8', $d->{$_}) for @fields;

        push @{$d->{categories}}, @{$o->{category}} ;
        $_ = encode('utf8', $_) for @{$d->{categories}};

        my $pid = $wp->newPost( $d, 1 );
        my $post_url = "$o->{base_url}/?p=$pid";

        return $post_url;
    };

    return ($write_sub, \$o->{base_url});
}


sub format_chapter {
    my ( $self, $c, $i ) = @_;
    my $j = sprintf("%03d", $i || $c->{id});

    my $d = {
        'title' => qq[$c->{writer} 《$c->{book}》 $j : $c->{title}],
        'description' => qq[<p>来自：<a href="$c->{url}">$c->{url}</a></p><br/>$c->{content}],
        'mt_keywords' => [ $c->{writer}, $c->{book} ],
        'categories' => [], 
    };

    return $d;
} ## end sub generate_chapter_url

no Moo;
1;
