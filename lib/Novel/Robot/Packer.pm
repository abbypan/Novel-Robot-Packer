# ABSTRACT: 小说打包引擎
=pod

=encoding utf8

=head1 支持输出类型

见 Nover::Packer:: 系列模块

=head1 FUNCTION

=head2 init_packer 初始化解析模块

   my $packer = Novel::Robot::Packer->new();

   my $pack_type = 'HTML';

   $packer->init_packer($pack_type);

=cut
use strict;
use warnings;
package  Novel::Robot::Packer;
use Moo;
use Novel::Robot::Packer::TXT;
use Novel::Robot::Packer::HTML;
use Novel::Robot::Packer::WordPress;

our $VERSION = 0.06;

sub init_packer {
    my ( $self, $site , $opt) = @_;
    my $s = $opt?'%$opt':'';
    my $packer = eval qq[new Novel::Robot::Packer::$site($s)];
    return $packer;
}

no Moo;
1;
