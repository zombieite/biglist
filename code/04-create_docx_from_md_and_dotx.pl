#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));
use File::Spec;
use Cwd qw(abs_path);

my $out_docx        = '/Users/firebird/Desktop/local/txt/original/nonfiction/route_66/2026-edition002/data/wasteland_firebirds_big_list-base.docx';
my $work_dir        = '/Users/firebird/Desktop/local/txt/original/nonfiction/route_66/2026-edition002/data';
# Your print-on-demand formatting is controlled by this DOCX.
# Make a DOCX that matches the POD template (margins, page size, headers/footers, fonts, etc).
# Pandoc calls this a "reference docx".
my $reference_docx  = '/Users/firebird/Desktop/local/txt/original/nonfiction/route_66/2026-edition002/data/wasteland_firebirds_big_list-template.docx';

sub ensure_dir {
  my ($d) = @_;
  -d $d or mkdir $d or die "Can't mkdir $d: $!";
}

ensure_dir($work_dir);
my $md_path = File::Spec->catfile($work_dir, 'book.md');

#    Convert Markdown -> DOCX using reference.docx for layout
#    This is the key: reference_docx defines page size/margins/fonts like your POD template.
my @cmd = (
  'pandoc',
  $md_path,
  '-o', $out_docx,
  '--reference-doc=' . $reference_docx,
);

print "Running:\n  " . join(' ', map { /\s/ ? qq("$_") : $_ } @cmd) . "\n";
system(@cmd) == 0 or die "pandoc failed (exit " . ($? >> 8) . ")\n";

print "Wrote DOCX: $out_docx\n";
print "Next: open DOCX in Pages.\nClick Document, Section, uncheck Left and Right are Different.\nClick Document, Document, Footer. Then go to the footer and click it and Insert Page Number. Do any other needed tweaks then export PDF.\n";

system('open', $out_docx);
