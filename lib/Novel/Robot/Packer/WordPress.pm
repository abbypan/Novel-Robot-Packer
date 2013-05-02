# ABSTRACT: 把小说发布到WordPress
package Novel::Robot::Packer::WordPress;

use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Packer::Base';

use WordPress::XMLRPC;
use Encode;


sub BUILD {
    my ( $self ) = @_;

    $self->{base_url}=~s#/$##;
    
    $self->{wordpress} = WordPress::XMLRPC->new( {   
            username => $self->{usr},
            password => $self->{passwd},
            proxy    => "$self->{base_url}/xmlrpc.php",
        });

    $self;
}


sub open_packer {
    my ($self, $index) = @_;
    $self->{tags}       = exists $self->{tag} ? [ split ',', $self->{tag} ] : [];
    $self->{categories} = exists $self->{category} ? [ split ',', $self->{category} ] : [];
}


sub format_chapter {
    my ( $self, $c, $i ) = @_;
    $i ||= $c->{id};

    my $u = $c->{url};
    my $d = {
        'title' => qq[$c->{writer} 《$c->{book}》 $i : $c->{title}],
        'description' => qq[<p>来自：<a href="$u">$u</a></p><p></p>$c->{content}],
        'mt_keywords' => [ $c->{writer}, $c->{book} ],
    };

    push @{ $d->{mt_keywords} }, @{ $self->{tags} } if ( @{ $self->{tags} } );
    push @{ $d->{categories} }, @{ $self->{categories} } if ( @{ $self->{categories} } );


    $d->{$_} = encode('utf8', $d->{$_}) for(qw/title description/);
    for my $k (qw/mt_keywords categories/){
        $_ = encode('utf8', $_) for @{$d->{$k}};
    }

    my $pid = $self->{wordpress}->newPost( $d, 1 );
    my $post_url = "$self->{base_url}/?p=$pid";

    return $post_url;
} ## end sub generate_chapter_url

no Moo;
1;
