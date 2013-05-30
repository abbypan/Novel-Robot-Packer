# ABSTRACT: 小说打包引擎
use strict;
use warnings;
package  Novel::Robot::Packer;
use Moo;
use Novel::Robot::Packer::TXT;
use Novel::Robot::Packer::HTML;
use Novel::Robot::Packer::WordPress;

our $VERSION = 0.05;

sub init_packer {
    my ( $self, $site , $opt) = @_;
    my $s = $opt?'%$opt':'';
    my $packer = eval qq[new Novel::Robot::Packer::$site($s)];
    return $packer;
}

no Moo;
1;
