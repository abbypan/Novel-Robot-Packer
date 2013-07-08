# ABSTRACT: 把小说发布到WordPress
=pod

=encoding utf8

=head1 FUNCTION

=head2 new 初始化

   my $packer = Novel::Robot::Packer::WordPress->new({
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


sub BUILD {
    my ( $self ) = @_;

    $self->{base_url}=~s#/$##;
    $self->{tag} ||= [];
    $self->{category} ||= [];
    
    $self->{wordpress} = WordPress::XMLRPC->new( {   
            username => $self->{usr},
            password => $self->{passwd},
            proxy    => "$self->{base_url}/xmlrpc.php",
        });

    $self;
}


sub open_packer {
    my ($self, $index_ref) = @_;

    my $write_sub = sub {
        my ($d) = @_;

        my $pid = $self->{wordpress}->newPost( $d, 1 );
        my $post_url = "$self->{base_url}/?p=$pid";

        return $post_url;
    };

    return $write_sub;
}


sub format_chapter {
    my ( $self, $c, $i ) = @_;
    my $j = sprintf("%03d", $i || $c->{id});

    my $d = {
        'title' => qq[$c->{writer} 《$c->{book}》 $j : $c->{title}],
        'description' => qq[<p>来自：<a href="$c->{url}">$c->{url}</a></p><p></p>$c->{content}],
        'mt_keywords' => [ $c->{writer}, $c->{book} ],
        'categories' => [], 
    };
    push @{$d->{mt_keywords}}, @{$self->{tag}} ;
    $d->{mt_keywords} = join(", ", @{$d->{mt_keywords}});

    push @{$d->{categories}}, @{$self->{category}} ;
    $_ = encode('utf8', $_) for @{$d->{categories}};

    my @fields = qw/title description mt_keywords/;
    $d->{$_} = encode('utf8', $d->{$_}) for @fields;

    return $d;
} ## end sub generate_chapter_url

no Moo;
1;
