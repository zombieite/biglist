#!/usr/bin/env perl
use strict;
use warnings;
use GD::Barcode::QRcode;
use URI::Escape qw(uri_escape_utf8);
use File::Path  qw(make_path);
use File::Basename;

my $input_file =
'/Users/firebird/Desktop/local/txt/original/nonfiction/route_66/2026-edition002/data/addresses.txt';
my $output_dir =
'/Users/firebird/Desktop/local/txt/original/nonfiction/route_66/2026-edition002/data/qr_codes';

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
            if ($count % 2 == 1) {
                $pad = $w;
            }
            my $canvas = GD::Image->new( $w + $w, $h );
            my $white  = $canvas->colorAllocate( 255, 255, 255 );
            my $black = $canvas->colorAllocate(0,0,0);
            $canvas->filledRectangle( 0, 0, $w + $pad, $h, $white );
            $canvas->copy( $qr, $pad, 0, 0, 0, $w, $h );
            $canvas->rectangle(0, 0, $w + $w - 1 , $h - 1, $black);
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
}

main();

