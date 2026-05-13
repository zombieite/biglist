#!/usr/bin/env perl
use strict;
use warnings;
use GD::Barcode::QRcode;
use URI::Escape qw(uri_escape_utf8);
use File::Path  qw(make_path);
use File::Basename;
use Cwd qw(abs_path);

my $input_file = './data/addresses.txt';
my $output_dir = './data/qr_codes';

sub main {

    # clean out old QR codes if present
    mkdir $output_dir;
    opendir( my $dh, $output_dir ) or die "Can't open $output_dir: $!";
    while ( my $file = readdir($dh) ) {
        next if $file eq '.' or $file eq '..';
        my $path = "$output_dir/$file";
        next if -d $path;    # skip subdirectories
        unlink($path) or warn "Couldn't delete $path: $!";
    }
    closedir($dh);

    # Check if input file exists
    unless ( -e $input_file ) {
        print
"Error: Could not find '$input_file'. Please create it with one address per line.\n";
        return;
    }

    # Create output directory if it doesn't exist
    unless ( -d $output_dir ) {
        make_path($output_dir)
          or die "Failed to create directory $output_dir: $!";
    }

    print "Reading addresses from $input_file...\n";

    open my $fh, '<:encoding(UTF-8)', $input_file
      or die "Could not open '$input_file': $!";

    my $count = 0;

    while ( my $address = <$fh> ) {
        chomp $address;

        # Skip empty lines
        next unless $address =~ /\S/;

        $count++;

        # 1. Create the Google Maps URL
        # uri_escape handles spaces and special characters
        my $query    = uri_escape_utf8($address);
        my $maps_url = "https://www.google.com/maps/search/?api=1&query=$query";

        # 2. Generate the QR Code
        # Ecc => 1 is Error Correction Level L (Low)
        # ModuleSize controls the pixel size of the blocks
        my $qrobj =
          GD::Barcode::QRcode->new( $maps_url, { Ecc => 1, ModuleSize => 4 } );

        print "$maps_url\n";

        if ($qrobj) {

            # 3. Create a safe filename
            # Remove characters that are unsafe for filenames
            my $safe_name = $address;
            $safe_name =~ s/[^a-zA-Z0-9_\- ]//g;
            $safe_name =~ s/ /_/g;

            # Limit length to avoid filesystem errors
            $safe_name = substr( $safe_name, 0, 30 );

            my $filename = sprintf( "%03d_%s.png", $count, $safe_name );
            my $filepath = "$output_dir/$filename";

            open my $img_fh, '>', $filepath
              or die "Could not open '$filepath' for writing: $!";
            binmode $img_fh;

            # Adding some padding to left or right side, alternating
            my $qr = $qrobj->plot();
            my ( $w, $h ) = $qr->getBounds();
            my $pad = 0;
            if ( $count % 2 == 1 ) {
                $pad = $w;
            }
            my $canvas = GD::Image->new( $w + $w, $h );
            my $white  = $canvas->colorAllocate( 255, 255, 255 );
            my $black  = $canvas->colorAllocate( 0,   0,   0 );
            $canvas->filledRectangle( 0, 0, $w + $pad, $h, $white );
            $canvas->copy( $qr, $pad, 0, 0, 0, $w, $h );
            $canvas->rectangle( 0, 0, $w + $w - 1, $h - 1, $black );
            print $img_fh $canvas->png();

            close $img_fh;

            print "[$count] Saved: $filename\n";
        }
        else {
            print "[$count] Error generating QR code for: $address\n";
        }
    }

    close $fh;
    print "\nDone! Check the '$output_dir' folder for your codes.\n";

    # Input: address text file (one address per line)
    my $addresses_txt = './data/addresses.txt';
    my $out_csv       = './data/addresses_and_qr_locations.csv';

    # Folder containing QR images
    my $qr_dir = './data/qr_codes/';

    # QR filename pattern:
    # - If your files are like 001.png ... 434.png, set:
    my $qr_ext         = 'png';
    my $qr_pad         = 3;       # 3 => 001, 002, ...
    my $qr_start_index = 1;

    # If your QR files are like "qr_001.png" or "QR-001.png", set prefix/suffix:
    my $qr_prefix = '';           # e.g. 'qr_'
    my $qr_suffix = '';           # e.g. '' or '_code'

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
        if ( $s =~ /[",]/ ) {
            $s =~ s/"/""/g;
            return qq("$s");
        }
        return $s;
    }

    # 1) Index QR directory by leading 3 digits
    my %qr_for_num;       # "268" -> "/abs/path/to/268_Whatever.png"
    my %dupes_for_num;    # track duplicates

    my $qr_dir_abs = abs_path($qr_dir) // $qr_dir;

    opendir( my $dh, $qr_dir ) or die "Can't open QR directory '$qr_dir': $!";
    while ( my $f = readdir($dh) ) {
        next if $f eq '.' || $f eq '..';

# Match: 3 digits at start, then underscore, then anything, ending .png (case-insensitive)
# Example: 268_Newkirk_Ghost_Town_Newkirk_NM_.png
        next unless $f =~ /^(\d{3})_.+\.png\z/i;

        my $num  = $1;    # keep as 3-digit string
        my $full = File::Spec->catfile( $qr_dir_abs, $f );
        $qr_for_num{$num} = $full;
    }
    closedir($dh);

    # Warn about duplicates (same leading number)
    for my $num ( sort keys %dupes_for_num ) {
        warn "Duplicate QR files for '$num':\n  kept: $qr_for_num{$num}\n"
          . join( "", map { "  dup:  $_\n" } @{ $dupes_for_num{$num} } );
    }

    # 2) Read addresses + write CSV rows
    open my $in,  '<', $addresses_txt or die "Can't open $addresses_txt: $!";
    open my $out, '>', $out_csv       or die "Can't write $out_csv: $!";

    print $out "address,qr_image\n";

    my $line_no = 0;
    while ( my $addr = <$in> ) {
        $line_no++;
        $addr =~ s/\R\z//;    # chomp

# If blank lines should still count toward numbering, DO NOT skip them.
# If you want to skip blanks, uncomment the next line, but be aware it shifts numbering:
# next if $addr =~ /^\s*$/;

        my $idx = $qr_start_index + ( $line_no - 1 );
        my $num = sprintf( "%0*d", $qr_pad, $idx );     # "001", "002", ...

        my $qr_path = $qr_for_num{$num} // '';

        if ( !$qr_path ) {
            my $msg =
"Missing QR PNG for line $line_no (expected leading number '$num')\n";
            die $msg;
        }

        print $out csv_escape($addr) . "," . csv_escape($qr_path) . "\n";
    }

    close $in  or die "Error closing $addresses_txt: $!";
    close $out or die "Error closing $out_csv: $!";

    print "Wrote CSV: $out_csv\n";

    my $addresses_txt = './data/addresses.txt';
    my $qr_dir        = './data/qr_codes';
    my $work_dir      = './data';

# How line 1 maps to file number: line 1 => 001_*.png, line 268 => 268_*.png, etc.
    my $qr_start_index = 1;    # change if needed (placeholder)
    my $qr_pad         = 3;    # 3-digit numbers

    # Image sizing in the DOCX (pandoc understands inches, cm, mm).
    my $qr_width = '4.0in';

  # Where to put QR relative to address is handled by the reference.docx styles.
  # This script outputs: Address text, blank line, QR image, page break.

    # If a QR is missing: 1 = die, 0 = warn and leave blank
    my $die_on_missing = 1;

    sub ensure_dir {
        my ($d) = @_;
        -d $d or mkdir $d or die "Can't mkdir $d: $!";
    }

    sub md_escape {
        my ($s) = @_;
        $s //= '';
        $s =~ s/\R/ /g;          # collapse newlines
        $s =~ s/^\s+|\s+$//g;    # trim
                                 # Minimal escaping for markdown:
        $s =~ s/([\\`*_{}\[\]()#+\-.!|>])/\\$1/g;
        return $s;
    }

    # Index QR directory by leading 3 digits
    my %qr_for_num;
    my $qr_dir_abs = abs_path($qr_dir) // $qr_dir;

    opendir( my $dh, $qr_dir ) or die "Can't open QR directory '$qr_dir': $!";
    while ( my $f = readdir($dh) ) {
        next if $f eq '.' || $f eq '..';
        next unless $f =~ /^(\d{3})_.+\.png\z/i;    # 268_Something.png
        my $num  = $1;
        my $full = File::Spec->catfile( $qr_dir_abs, $f );

        # If duplicates exist for same leading number, keep the first and warn.
        if ( exists $qr_for_num{$num} ) {
            warn
"Duplicate QR for $num:\n  kept: $qr_for_num{$num}\n  dup:  $full\n";
            next;
        }
        $qr_for_num{$num} = $full;
    }
    closedir($dh);

    # Build a Pandoc-flavored Markdown file with page breaks
    ensure_dir($work_dir);
    my $md_path = File::Spec->catfile( $work_dir, 'book.md' );

    open my $in, '<', $addresses_txt or die "Can't open $addresses_txt: $!";
    open my $md, '>', $md_path       or die "Can't write $md_path: $!";

   # .md breaks that can be understood by pandoc and translated into word breaks
    my $line_break = "  \n";
    my $page_break =
      "```{=openxml}\n<w:p><w:r><w:br w:type=\"page\"/></w:r></w:p>\n```\n\n";

    # Title page
    print $md
"Wasteland Firebird's Big List${line_break}of the Best Things On Route 66${line_break}by Wasteland Firebird (John Binns)${line_break}Second Edition Summer 2026 Centennial${line_break}";
    print $md $page_break;

    # Copyright page
    print $md
"Copyright © 2026 John Binns${line_break}All rights reserved${line_break}wastelandfirebird\@gmail.com${line_break}youtube.com/wastelandfirebird${line_break}wastelandfirebird.com${line_break}";
    print $md $page_break;

    # Dedication
    print $md
"In 1987, Angel Delgadillo saved Route 66.${line_break}In 2006, Pixar's Cars saved Route 66.${line_break}2026 is the Centennial of Route 66.${line_break}Who will save it now, if not you and me?${line_break}";
    print $md $page_break;

    # Introduction
    print $md qq|
Prepare to be inspired
${line_break}
On July 4, 1976, I wasn't even four years old. But, that year, I learned a big word. Bicentennial. Everyone was saying it so much. How could I not have learned it? "Bicentennial." It was spoken with such obvious reverence that my young ears paid attention.
${line_break}
Fifty years later, I am the one speaking reverence to young ears. Are you paying attention?
${line_break}
Say it with me. "Semiquincentennial." Do any three-year-olds know that word? How many adults know it? Semiquincentennial.
${line_break}
Semi means half, quin means five, cent means hundred, ennial means years. The United States of America has now existed for half of 500 years.
${line_break}
I was hoping for another Freedom Train, a Wagon Train Pilgrimage, NYC's Operation Sail, TV shows, special coins, special edition cars, fireworks, air shows, car shows, parades, and red-white-and-blue everything. A few of those things are happening, but something has definitely changed in the last fifty years. The reverence is gone.
${line_break}
When I discovered that Route 66 would have its Centennial in the same year as America's Semiquincentennial, I went to work. I had to do something to bring that reverence back.
${line_break}
I traveled Route 66 four times. I made a bunch of YouTube videos about it. I took a lot of notes. I drew up flyers for a free event I was calling The Great Route 66 Centennial Convergence. I made t-shirts and keychains based on hand-drawn art. I commissioned miniature "Muffler Man" action figures of myself. I promoted this event so much that I was kicked off of Facebook forever for being a "spammer."
${line_break}
Most importantly, I created the First Edition of this book. Like the t-shirts, keychains, and action figures, the First Edition was never for sale. It was free for Convergence participants. There are still a few copies floating around out there.
${line_break}
The Great Route 66 Centennial Convergence came to an end on April 30, 2026. But people kept asking for copies of the book. So here it is. The Second Edition. You can buy it at wastelandfirebird.com. You might still manage to find a free copy, if you look hard enough. I always tell people to check the Route 66 of Chenoa IL Roadside Attraction Tourist Info booth. You never know what you might find in that thing.
${line_break}
Will there ever be another Convergence? I'll put it this way. I'll be traveling Route 66 as much as I can for the rest of my life. I'd be delighted if you, your friends, and your family, found me, followed me, and asked me questions, all along the way. But pay attention to my answers. And pay attention to my reverence.
${line_break}
Route 66 has always represented the American Dream. If we save Route 66, we save the American Dream. If we save the American Dream, we save America. If we save America, we save the world. Because the American Dream is not just America's dream. It's everyone's dream.
${line_break}
|;
    print $md $page_break;

    # How to use this book
    print $md qq|
How to use this book
${line_break}
This book is a list of QR codes that represent online directions to each of my favorite places on Route 66. You can scan these QR codes with your phone by pointing the phone's camera at them. If you scan every QR code, and visit every place in this book, you will approximately follow Route 66. There is no app that you need to download.
${line_break}
If you want to follow Route 66 more exactly, you'll need to do more research. But be aware that there never was a single "Route 66." There have always been many "alignments" (alternate routes). And nowadays, much of what used to be known as "Route 66" consists of potholed roads, dirt roads, private roads, government roads, and dead ends. If you want to explore all of it, you'd better give yourself at least a year.
${line_break}
Some of the passport-style books you'll find on the Route require small businesses to pay thousands of dollars for the privilege of being advertised in those books. I'm not saying that's a bad thing. I'm just saying it's something you should know. Many businesses along the Route have custom rubber "passport stamps." I've left an empty space beside all of the QR codes for those stamps, if you want to use them to mark your progress. You could also use those spaces for notes, signatures, stickers, or just big checkmarks.
${line_break}
No one paid to be in this book. This book is nothing more than a list of places and people that I love.
${line_break}
|;
    print $md $page_break;

    my $line_no = 0;
    while ( my $addr = <$in> ) {
        $line_no++;
        $addr =~ s/\R\z//;    # chomp

# DO NOT skip blank lines unless you're sure your numbering isn't line-based.
# If you want to skip blank lines, you must also adjust how you pick the QR number.
# next if $addr =~ /^\s*$/;

        my $idx = $qr_start_index + ( $line_no - 1 );
        my $num = sprintf( "%0*d", $qr_pad, $idx );     # "001", "268", ...

        my $qr_path = $qr_for_num{$num} // '';

        if ( !$qr_path ) {
            my $msg =
"Missing QR PNG for line $line_no (expected leading number '$num')\n";
            die $msg if $die_on_missing;
            warn $msg;
        }

# Address (as plain paragraph). If you want it to be, say, a big bold title,
# define a style in reference.docx and switch to it later via a pandoc Lua filter.
        print $md md_escape($addr), "\n\n";

        # QR image
        if ($qr_path) {

            # Pandoc supports attribute syntax: {width=...}
            print $md "![]($qr_path){width=$qr_width}\n\n";

            # If you prefer height:
            # print $md "![]($qr_path){height=$qr_height}\n\n";
        }
        else {
            print $md "\n";    # leave blank spot if missing
        }

        # Page break
        print $md $page_break;
    }

    close $in or die "Error closing $addresses_txt: $!";
    close $md or die "Error closing $md_path: $!";

    my $out_docx = './data/wasteland_firebirds_big_list-base.docx';
    my $work_dir = './data';

# Your print-on-demand formatting is controlled by this DOCX.
# Make a DOCX that matches the POD template (margins, page size, headers/footers, fonts, etc).
# Pandoc calls this a "reference docx".
    my $reference_docx = './data/wasteland_firebirds_big_list-template.docx';

    ensure_dir($work_dir);
    my $md_path = File::Spec->catfile( $work_dir, 'book.md' );

#    Convert Markdown -> DOCX using reference.docx for layout
#    This is the key: reference_docx defines page size/margins/fonts like your POD template.
    my @cmd = (
        'pandoc', $md_path, '-o', $out_docx,
        '--reference-doc=' . $reference_docx,
    );

    print "Running:\n  "
      . join( ' ', map { /\s/ ? qq("$_") : $_ } @cmd ) . "\n";
    system(@cmd) == 0 or die "pandoc failed (exit " . ( $? >> 8 ) . ")\n";

    print "Wrote DOCX: $out_docx\n";
    print
"Next: open DOCX in Pages.\nClick Document, Section, uncheck Left and Right are Different.\nClick Document, Document, Footer. Then go to the footer and click it and Insert Page Number. Do any other needed tweaks then export PDF.\n";

    system( 'open', $out_docx );

}

main();

