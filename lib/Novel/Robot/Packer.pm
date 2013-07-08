# ABSTRACT: 小说打包引擎
=pod

=encoding utf8

=head1 支持输出类型

    TXT  : txt形式的小说

    HTML : 网页形式的小说

    WordPress : 将小说发布到WordPress空间

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

our $VERSION = 0.07;

sub init_packer {
    my ( $self, $site , $opt) = @_;
    my $s = $opt?'%$opt':'';
    my $packer = eval qq[new Novel::Robot::Packer::$site($s)];
    return $packer;
}

no Moo;
1;
