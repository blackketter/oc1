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
sub parse_args
{
    my $input_filename = $ARGV[0];
    if (!-f $input_filename) {
	print "Couldn't find $input_filename\n";
	usage();
    }
    my $output_filename = "$input_filename.txt";
    my $input = new FileHandle($input_filename);
    if (!$input) {
	print "Couldn't open $input_filename for reading\n";
	usage();
    }
    
    my $output = new FileHandle($output_filename, "w");
    if (!$output) {
	print "Coudln't open $output_filename for writing\n";
	usage();
    }
    return ($input, $output);
}
sub parse_bom
{
    my ($input) = @_;
    my $header = undef;
    my $bom = [];
    my $line;
    my %temp_bom = ();
    while ($line = <$input>) {
	$line =~ s:	:	 :g; # <-  Stupid; add a space after the tab to make sure split keeps all fields. 
	$line =~ s:::g;
	$line =~ s:\n::g;
#	print $line . "\n";
#	$line="$line\tjunk";
	my @line = split(/\t+/, $line, -1);
	@line = grep {s:^ ::; 1} @line;  # <- stupid:  remove the space.
	if (@line > 3) {
	    if (!defined $header) {
		$header = \@line;
	    } else {
		my $item = shift(@line);
		my $quantity = shift(@line);
		my $reference = shift(@line);
		my @properties = @line;
		my $properties = \@properties;
		my $property_string = join("#", @properties);
		if (!defined $temp_bom{$property_string}) {
		    $temp_bom{$property_string} = [ [] , $properties ];
		}
		push(@{$temp_bom{$property_string}->[0]}, $reference);
	    }
	}
    }
    shift(@$header);
    foreach my $key (keys(%temp_bom)) {
	my $info = $temp_bom{$key};
	my $quantity = @{$info->[0]};
	my $references = $info->[0];
	my $properties = $info->[1];
	push(@$bom, [$quantity, $references, $properties]);
    }
    return ($header, $bom);
}

sub print_bom
{
    my ($output, $header, $bom) = @_;
    print $output join("\t", @$header) . "\n";
    foreach my $line (@$bom) {
#	print Dumper($line);
	my ($quantity, $references, $properties) = @$line;
	print $output "$quantity\t" . join(",", @$references) . "\t" . join("\t", @$properties) . "\n";
    }
}


my ($input, $output) = parse_args();
my ($header, $bom)  = parse_bom($input);
print_bom($output, $header, $bom);
$input->close();
$output->close();
