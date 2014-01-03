# ABSTRACT: 打包小说为MOBI
package Novel::Robot::Packer::MOBI;
use strict;
use warnings;
use utf8;

use Moo;
extends 'Novel::Robot::Packer::Base';

use EBook::MOBI;
use Encode;

has '+suffix'    => ( default => sub {'mobi'} );

sub open_packer {
    my ($self, $index_ref, $o) = @_;

    my $book = EBook::MOBI->new();

    my $fname = $self->format_filename($index_ref, $o);
    $book->set_filename($fname);

    $book->set_title(encode("UTF-8", $index_ref->{book}));
    $book->set_author(encode("UTF-8", $index_ref->{writer}));
    $book->{header_opts}={ language => 'zh-cn' };
    #$book->set_encoding(':encoding(UTF-8)');
    $book->set_encoding(':utf8');

    $book->add_toc_once();
    $book->add_pagebreak();

    my $write_sub = sub {
        my ($c) = @_;
        return unless($c);
        $c = encode("UTF-8", $c);
        $book->add_mhtml_content($c);
        $book->add_pagebreak();
    };

    my $end_sub = sub {
        $book->make();
        $book->print_mhtml();
        return $book->save() unless(exists $o->{write_scalar});

        use File::Temp qw/ tempfile tempdir /;
        my ($fh, $temp_f) = tempfile();
        $book->set_filename($temp_f);

        $book->save();
        my $mhtml_data;
        {
            local $/=undef;
            $mhtml_data=<$fh>;
        }

        return (
            \$mhtml_data, 
            writer => $index_ref->{writer}, 
            book => $index_ref->{book}
        );
    };

    return ($write_sub, $end_sub);
}

sub format_chapter {
    my ( $self, $chap , $id) = @_;

    $chap->{id} ||= $id || 1;
    my $j = sprintf( "%03d#", $chap->{id});
    
    $chap->{title} ||= '[锁]';
    $chap->{content} ||='';

    for($chap->{content}){
        s/^\s*|\s*$//s;
        s/\r?\n+/\n/gs;
        s/<br\s*\/?\s*>/\n\n/gsi;
        s#</p>#\n\n#gsi;
        s/<[^>]+>//gs;
        s#(\S.*?)\n+#<p> $1 </p>\n#sg;
    }

    my $floor = <<__FLOOR__;
<h1>$j $chap->{title}</h1>
$chap->{content}
__FLOOR__

    return $floor;
} ## end sub format_chapter

no Moo;
1;
