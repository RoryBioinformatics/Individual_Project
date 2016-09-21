#!/usr/bin/perl -w

use strict;
use warnings;
use Statistics::R;

# Program to handle csv files and clean according to the 80% rule using the R program. 


# Handle input file and store in a scalar.
my $infile = $ARGV[0];
chomp $infile;

# Reads the wd of the chosen file and reads it into R.
my $R = Statistics::R->new();
$R->startR;
print "Finding file location. ";
$R->run("getwd()");
my $wd = $R->read;
chop $wd;

# Used to remove the quotation marks and typical R response for the getwd() command
my $dw = reverse ($wd);
chop $dw;
chop $dw;
chop $dw;
chop $dw;
chop $dw;
$wd = reverse ($dw);
print "Done.\n";
print "Reading file. ";
# Read the dataframe into the R program
$R->run("$infile <- read.csv('$wd/$infile', row.names=1)");
print "Done.\n";

print "\nChatting with R. ";
# Uses plyr module for the counting function
$R->run("library(plyr)");

# Takes column and row data from the dataset and takes the file name into a scalar
$R->run("a<-colnames($infile)");
$R->run("a");
my $colnames = $R->read;
$R->run("b<-rownames($infile)");
$R->run("b");
my $rownames = $R->read;
$R->run("length(a)");
my $collength = $R->read;
$R->run("length(b)");
my $rowlength = $R->read;
$R->run("myFile <-$infile");
print "Done.";

# Cuts the [1] response from R row length reads.
my $lengthrow = reverse ($rowlength);
chop $lengthrow;
chop $lengthrow;
chop $lengthrow;
chop $lengthrow;
$rowlength = reverse ($lengthrow);

# Reads each row to determine amount of empty results in each (equal to 0)
my $count = 1;
my @rows = split (" ", $rownames);
my @names;
print "\nLearning names. ";
foreach (@rows){
	if ($_ =~ m/\d+_\d+/){
		push (@names, $_);
	}
}
print "Done.\n";

# Cuts the [1] response from R column length reads.
my $lengthcol = reverse ($collength);
chop $lengthcol;
chop $lengthcol;
chop $lengthcol;
chop $lengthcol;
$collength = reverse ($lengthcol);
print "\nLocating Mop.";
while ($count < $rowlength){
	my $freq = 0;
	my $row = $names[$count];
	$R->run("r<-myFile [$row, ]");
	$R->run("count(as.numeric(myFile [$row,]))");
	my $countfunc = $R->read;
	if ($countfunc =~ m/1\s+\d+.\d+\s+(\d+)/){
		$freq = $1;
		print ".";
	}
	my $rule = ($collength - $freq);
	if ($rule/$collength < 0.8){
		$R->run("myFile <- data.frame(myFile[-$count, ])");
		print $row;
	}
	$count ++;

}
my $filename = $infile;
chop $infile;
chop $infile;
chop $infile;
chop $infile;
print "\nData Polished!";
$R->run("write.csv(myFile, file='$infile.clean.csv')");

$R->stopR;
