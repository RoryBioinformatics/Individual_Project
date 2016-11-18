#!/usr/bin/perl -w

use strict;
use warnings;
use Tk;

# Processor.pl GUI
############################################################

my $mw = new MainWindow;
my @files;
my $minimum;
my $maximum;
my $intensity;
my $dist;
my $dir = system "pwd";
my $file2;

# File entry frame
my $frame_top = $mw -> Frame();
my $lab = $frame_top -> Label(-text=>"Find your file:   ");
my $ent = $frame_top -> Entry(-width=>60, -text=>"$file2");
my $but = $frame_top -> Button(-text=>"Submit file", -command =>\&push_button);
my $but2 = $frame_top -> Button(-text=>"Choose file", -command =>\&file_list);

# Parameter setting frame
my $frame_middle = $mw -> Frame();
my $lab_dist = $frame_middle -> Label(-text=>"Set minimum peak distance:");
my $ent_dist = $frame_middle -> Entry();
my $lab_dist2 = $frame_middle -> Label(-text=>"This will set the minimum m/z distance between two\n peaks to ensure replicate peaks are not recorded.");
my $lab_cutoff = $frame_middle -> Label(-text=>"Set intensity cutoff:");
my $ent_cutoff = $frame_middle -> Entry();
my $lab_cutoff2 = $frame_middle -> Label(-text=>"The intensity cutoff is designed to remove low \nlevel noise in the peak data.");
my $lab_min = $frame_middle -> Label(-text=>"Set minimum m/z:");
my $ent_min = $frame_middle -> Entry();
my $lab_min2 = $frame_middle -> Label(-text=>"This sets the minimum m/z to reduce search area.");
my $lab_max = $frame_middle -> Label(-text=>"Set maximum m/z:");
my $ent_max = $frame_middle -> Entry();
my $lab_max2 = $frame_middle -> Label(-text=>"This sets the maximum m/z to reduce search area.");

# File check/submission frame
my $frame_bottom = $mw -> Frame();
my $txt = $frame_bottom -> Text(-width=>70, -height=>10);
my $srl_y = $frame_bottom -> Scrollbar(-orient=>'v');
my $srl_x = $frame_bottom -> Scrollbar(-orient=>'h');
my $lab_txt = $frame_bottom -> Label(-text=>"Added Files:");
my $but_submit = $frame_bottom -> Button(-text=>"Submit",-command =>\&param_entry);
#my $but_quit = $frame_bottom -> Button(-text=>"Quit",-command => sub { exit });
$txt -> configure(-yscrollcommand=>['set', $srl_y],
        -xscrollcommand=>['set',$srl_x]);

# Grid for widget positioning
$lab -> grid(-row=>1,-column=>1);
$ent -> grid(-row=>1,-column=>2);
$but -> grid(-row=>1,-column=>4);
$but2 -> grid(-row=>1,-column=>3);
$frame_top -> grid(-row=>1,-column=>1,-columnspan=>4);

$lab_dist -> grid(-row=>2,-column=>1);
$ent_dist -> grid(-row=>2,-column=>2);
$lab_dist2 -> grid(-row=>2,-column=>3);
$lab_cutoff -> grid(-row=>3,-column=>1);
$ent_cutoff -> grid(-row=>3,-column=>2);
$lab_cutoff2 -> grid(-row=>3,-column=>3);
$lab_min -> grid(-row=>4,-column=>1);
$ent_min -> grid(-row=>4,-column=>2);
$lab_min2 -> grid(-row=>4,-column=>3);
$lab_max -> grid(-row=>5,-column=>1);
$ent_max -> grid(-row=>5,-column=>2);
$lab_max2 -> grid(-row=>5,-column=>3);
$frame_middle -> grid(-row=>2,-column=>1,-columnspan=>3);

$lab_txt -> grid(-row=>1,-column=>1);
$txt -> grid(-row=>2,-column=>1);
$srl_y -> grid(-row=>2,-column=>2,-sticky=>"ns");
$srl_x -> grid(-row=>3,-column=>1,-sticky=>"ew");
$but_submit -> grid(-row=>4,-column=>1);
$frame_bottom -> grid(-row=>3,-column=>1,-columnspan=>4);

MainLoop;

# Functions

sub push_button {
	my $file = $ent -> get();
	push (@files, $file2);
	$txt -> insert('end',"$file\n");
	print @files;
	$ent -> delete(0,'end');
}

sub file_list {
	my $FSref = $mw->FileSelect();
	$file2 = $FSref->Show;
	$ent -> insert('end',"$file2");
}

sub param_entry {
	$minimum = $ent_min -> get();
	$maximum = $ent_max -> get();
	$intensity = $ent_cutoff -> get();
	$dist = $ent_dist -> get();

# Processor.pl script below
#################################################################
#################################################################


# Handle input file and store in a scalar.
my $filesorter = join (" ",@files);
chomp $filesorter;
@files = split (" ",$filesorter);
foreach (@files){
my $infile = $_;
my $filename;
print "$infile \n";

# Creates time recording for file
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon += 1;
print "$mday/$mon/$year $hour:$min:$sec\n";

# Takes file name from location 
my @splitter = split("/",$infile);
$infile = pop @splitter;
#unshift (@splitter,"~");
my $location = join ("/",@splitter);
print "@splitter\n";
print "$infile\n";

# Removes $infile file ending
if ($infile =~ m/(\w+.)\w+/){
	my $file = $1;
	my @list = split("", $file);
	pop @list;
	$filename = join ("", @list);
}
print "YOU ARE HERE $location\n";
system "cd";
system "cd $location";
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
			# Checks the size of the next given intensity against the current intensity. If the size is greater, the peak is not yet found. If the size is smaller, the peak is found and is stored. 
			# Also checks against the previous intensity to measure if the current peak is more than the previous iteration.
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

# Prints peaks on command line. Also reverses hash for later use.
my %reverse_peak = reverse %peak_intensities;
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
print PEAK "# $mday/$mon/$year- $hour:$min:$sec\n# $company: $machine\n# M/Z range: $lowMz-$highMz.\n# Peak Count- $peakCount\n# $filename Centroid Peaks data [Charged]\n# Chosen M/Z cutoff: $minimum - $maximum\n# Minimum distance between peaks: $dist\n# Peaks filtered at intensity of $intensity.\n";
print PEAK "Peak Intensity,Peak m/z";


# Sorts the M/z values into a descending list before checking related peaks on the reduced subroutine
my @desc = sort {$a <=> $b} (@v);
my @reduced = reduce(@desc);


my @sorted;

# Prints m/z-intensity points into file
foreach (@reduced){
	print PEAK "\n$reverse_peak{$_},$_";
	push (@sorted, $reverse_peak{$_});
}

# Sort and remove low (related) peak distances using the comp subroutine
@sorted = sort {$a <=> $b} (comp(@sorted));
print "\n";
sub comp {
# Compares the given array m/z to find peak intensity ratios between all m/z found.
	my $mz = join (" ",@_);
	my $instance;
	my @subtraction;
	my @mzs = split(" ",$mz);
	my $mzs = @mzs;
	print PEAK "\nIntensity Ratios:";
	while ($mzs > 0){	
		$instance = shift (@mzs);
		$mzs --;
		foreach (@mzs){
			my $dif = $_ / $instance;
			push (@subtraction, $dif);
			print PEAK "\n$_ / $instance,\t$dif";
		}		
	}
	my $sub = join (" ",@subtraction);
	return @subtraction;
}

sub reduce {
# Compares the given array m/z to find related m/z signatures
	my $mz = join (" ",@_);
	my $instance;
	my @subtraction;
	my @sublist;
	my @mzs = split(" ",$mz);
	my $mzs = @mzs;
	my @final;

	while ($mzs > 0){	
		$instance = shift (@mzs);
		$mzs --;
		foreach (@mzs){
			print "$_\t $mzs\t";
			my $chance = $_;
			$chance -= $instance;
			print "$chance\n";
			if (($chance >= $dist) && ($instance >= $minimum) && ($instance <= $maximum)){
				push (@subtraction, $instance);
				if (($mzs == 1) && ($_ >= $minimum) && ($_ <= $maximum)){
					push (@subtraction, $_);
				}
				last;
			}
			elsif (($chance < $dist) && ($reverse_peak{$_} > $reverse_peak{$instance})){
				push (@sublist, $instance);
 				if (($mzs == 1) && ($_ >= $minimum) && ($_ <= $maximum)){
					push (@subtraction, $_);
				}
			}
			elsif (($chance < $dist) && ($reverse_peak{$instance} > $reverse_peak{$_})){
				push (@sublist, $_);
				shift @mzs;
				unshift (@mzs, $instance);
 				if (($mzs == 1) && ($_ >= $minimum) && ($_ <= $maximum)){
					push (@subtraction, $_);
				}
				last;
			}
		}		
	}

	my $sub = join(" ",@subtraction);
	my $remove = join(" ", @sublist);

	foreach (@sublist){
		my $take = $_;
			$sub =~ s/$take //;
	}

	@final = split (" ",$sub);
	return @final;
}
}
close PEAK;
exit;
}
