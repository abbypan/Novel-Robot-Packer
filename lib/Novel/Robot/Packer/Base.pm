# ABSTRACT: 打包小说基础引擎
use strict;
use warnings;
package  Novel::Robot::Packer::Base;
use Moo;
use Encode::Locale;
use Encode;

sub format_filename {
    my ($self, $filename) = @_;
    $filename ||= $self->{filename};
    $self->{filename} = encode( locale  => $filename);
}

sub open_packer { }
sub format_before_index { }
sub format_index { }
sub format_after_index { }
sub format_before_chapter { }
sub format_chapter { }
sub format_after_chapter { }
sub close_packer { }


no Moo;
1;
