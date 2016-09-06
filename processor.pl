#!/usr/bin/perl -w

use strict;
use warnings;
use DateTime;

# Handle input file and store in a scalar.
my $infile = $ARGV[0];
chomp $infile;

my $filename;
# Creates time recording for file
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon += 1;
print "$mday/$mon/$year, $hour:$min:$sec";
# Asks for intensity cutoff to choose only intended peaks
print "\nPlease set intensity cutoff\n";
my $intensity = <STDIN>;
chomp $intensity;
# Removes $infile file ending
if ($infile =~ m/(\w+.)\w+/){
	my $file = $1;
	my @list = split("", $file);
	pop @list;
	$filename = join ("", @list);
}

# System call to read mzXML file and put into a new file
system "mscat $filename.mzXML > $filename.txt";

# Open new mzXML file for editing
open (TXT, "$filename.txt") or die ("Cannot Open .txt file.");
my $checker = 0;
my $checked = 0;
my $peak = 0;
my $prepeak = 1000;
my %peak_intensities;

# Opens file to find instances of matching 
while (<TXT>){
	# Use regex to match for key phrases to create hash for m/z 
	if ($_ =~ m/\s+1\s+ms1\s+(\d+.\d{4})\s+(\d+\.\d{2})\n/){
		# Checks against a given minimum intensity
		if ($2 >= $intensity ){
			$checker = $2;
			# Checks the size of the next given intensity against the current intensity. If the size is greater, the peak is not yet found. If the size is smaller, the peak is found and is stored. Also checks against the previous 				# intensity to measure if the current peak is more than the previous iteration.
			if ($peak < $checker){
				$prepeak = $peak;
				$peak = $checker;
				$checked = $1;
			}
			elsif (($peak > $checker) && ($peak > $prepeak)) {
				$peak_intensities{"$peak"}="$checked";
				$prepeak = $peak;
				$peak = $checker;
			}
			else {
				$prepeak = $peak;
				$peak = $checker;
				$checked = $1;
			} 
		}
	}
}
# Prints peaks on command line
my @k = keys %peak_intensities;
my @v = values %peak_intensities;
foreach (@k) {
	print  "Peak Intensity: $_ M/Z: $peak_intensities{$_}\n";
}
close TXT;

# Creates a peak intensity file
system "touch $filename.peak.txt";

# Opens the peak file for writing
open (PEAK, ">$filename.peak.txt") or die ("Cannot Open Writing (.peak.txt) File.");
my $company;
my $lowMz;
my $highMz;
my $machine;
my $peakCount;

# Takes extra information from the mzXML file to place in file.
open (mzXML, "$infile") or die ("Cannot open mzXML file.");
while (<mzXML>){
	if ($_ =~ m/value="(\w+\s?\w+)"/){$company = $1;}
	if ($_ =~ m/lowMz="(\d+)"/){$lowMz = $1;}
	if ($_ =~ m/highMz="(\d+)"/){$highMz = $1;}
	if ($_ =~ m/value="(\w+\s?\w+)"\S{1}><msIonisation/){$machine = $1;}
	if ($_ =~ m/peaksCount="(\d+)"/){$peakCount = $1;}

}
# Enters peak information into the file
print PEAK "# $mday/$mon/$year, $hour:$min:$sec\n# $company: $machine\n# M/Z range: $lowMz-$highMz.\n# Peak Count- $peakCount\n# $filename Centroid Peaks data [Charged]\n# Peaks filtered at intensity of $intensity.\n";
foreach (@k){
	print PEAK "$peak_intensities{$_},$_\n"
}




