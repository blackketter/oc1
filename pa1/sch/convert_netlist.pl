#!/usr/bin/perl -w
use strict;
use FileHandle;
use Data::Dumper;

# Converts a 1-item-per-line into a better formatted BOM.
sub usage
{
    print "usage:  perl convert_bom.pl <filename.bom>\n";
    print "\nResult is in filename.bom.txt\n";
    exit(-1);
}

if (@ARGV != 1) {
    usage();
}

my $input_filename = $ARGV[0];

my $file = new FileHandle($input_filename) or usage();
my @file = <$file>;
$file->close();
$file = new FileHandle($input_filename, 'w') or die "Couldn't open $input_filename for writing";
$file[0] = "!PADS-POWERPCB-V2007.0-METRIC! DESIGN DATABASE ASCII FILE 1.0:\n";
print $file @file;
$file->close();

