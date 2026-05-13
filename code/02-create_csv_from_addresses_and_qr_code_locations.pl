#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use List::Util qw(shuffle);
use Carp qw(confess);
$SIG{__WARN__} = sub { confess @_ };
use utf8;
use open qw(:std :encoding(UTF-8));
use File::Spec;
use File::Basename;
use Cwd qw(abs_path);

# ----------------------------
# USER CONFIG (edit these)
# ----------------------------

# Input: address text file (one address per line)
my $addresses_txt = './data/addresses.txt';
my $out_csv = './data/addresses_and_qr_locations.csv';

# Folder containing QR images
my $qr_dir = './data/qr_codes/';

# QR filename pattern:
# - If your files are like 001.png ... 434.png, set:
my $qr_ext  = 'png';
my $qr_pad  = 3;      # 3 => 001, 002, ...
my $qr_start_index = 1;

# If your QR files are like "qr_001.png" or "QR-001.png", set prefix/suffix:
my $qr_prefix = '';   # e.g. 'qr_'
my $qr_suffix = '';   # e.g. '' or '_code'

# If you already have exact filenames but not predictable, you can later swap
# this logic out for a lookup table.

# ----------------------------
# END USER CONFIG
# ----------------------------

sub csv_escape {
  my ($s) = @_;
  $s //= '';
  $s =~ s/\R/ /g;          # collapse any stray newlines
  $s =~ s/^\s+|\s+$//g;    # trim
  # Quote if it contains comma, quote, or leading/trailing spaces
  if ($s =~ /[",]/) {
    $s =~ s/"/""/g;
    return qq("$s");
  }
  return $s;
}

# 1) Index QR directory by leading 3 digits
my %qr_for_num;         # "268" -> "/abs/path/to/268_Whatever.png"
my %dupes_for_num;      # track duplicates

my $qr_dir_abs = abs_path($qr_dir) // $qr_dir;

opendir(my $dh, $qr_dir) or die "Can't open QR directory '$qr_dir': $!";
while (my $f = readdir($dh)) {
  next if $f eq '.' || $f eq '..';
  # Match: 3 digits at start, then underscore, then anything, ending .png (case-insensitive)
  # Example: 268_Newkirk_Ghost_Town_Newkirk_NM_.png
  next unless $f =~ /^(\d{3})_.+\.png\z/i;

  my $num = $1; # keep as 3-digit string
  my $full = File::Spec->catfile($qr_dir_abs, $f);
  $qr_for_num{$num} = $full;
}
closedir($dh);

# Warn about duplicates (same leading number)
for my $num (sort keys %dupes_for_num) {
  warn "Duplicate QR files for '$num':\n  kept: $qr_for_num{$num}\n"
     . join("", map { "  dup:  $_\n" } @{ $dupes_for_num{$num} });
}

# 2) Read addresses + write CSV rows
open my $in,  '<', $addresses_txt or die "Can't open $addresses_txt: $!";
open my $out, '>', $out_csv       or die "Can't write $out_csv: $!";

print $out "address,qr_image\n";

my $line_no = 0;
while (my $addr = <$in>) {
  $line_no++;
  $addr =~ s/\R\z//;  # chomp

  # If blank lines should still count toward numbering, DO NOT skip them.
  # If you want to skip blanks, uncomment the next line, but be aware it shifts numbering:
  # next if $addr =~ /^\s*$/;

  my $idx = $qr_start_index + ($line_no - 1);
  my $num = sprintf("%0*d", $qr_pad, $idx);   # "001", "002", ...

  my $qr_path = $qr_for_num{$num} // '';

  if (!$qr_path) {
    my $msg = "Missing QR PNG for line $line_no (expected leading number '$num')\n";
    die $msg;
  }

  print $out csv_escape($addr) . "," . csv_escape($qr_path) . "\n";
}

close $in  or die "Error closing $addresses_txt: $!";
close $out or die "Error closing $out_csv: $!";

print "Wrote CSV: $out_csv\n";

