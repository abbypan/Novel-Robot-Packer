# ABSTRACT: 打包小说基础引擎
=pod

=encoding utf8

=head1 FUNCTION

=head2 format_file_name 生成文件名

   my $filename = $self->format_file_name($fname);

=head2 open_packer 打开打包文件
   
   my $pk = $self->open_packer($index_ref);

=head2 format_before_index

  $self->format_before_index($pk, $index_ref);

=head2 format_index

  $self->format_index($pk, $index_ref);

=head2 format_before_chapter

  $self->format_before_chapter($pk, $index_ref);

=head2 format_chapter

  $self->format_chapter($pk, $chapter_ref, $chapter_id);

=head2 format_after_chapter

  $self->format_after_chapter($pk, $index_ref);

=head2 close_packer 
   
   $self->close_packer($pk, $index_ref);

=cut
use strict;
use warnings;
package  Novel::Robot::Packer::Base;
use Moo;
use Encode::Locale;
use Encode;

sub format_filename {
    my ($self, $filename) = @_;
    my $fname = encode( locale  => $filename);
    return $fname;
}

sub open_packer { }
sub format_before_index { }
sub format_index { }
sub format_before_chapter { }
sub format_chapter { }
sub format_after_chapter { }
sub close_packer { }


no Moo;
1;
