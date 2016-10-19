#!/usr/bin/perl -w

use strict;
use warnings;

# Handle input file and store in a scalar.
my $infile = $ARGV[0];
chomp $infile;
my $count1 = 0;
my $count2 = 0;
my $count3 = 0;
my $number;
my $pval;
my $r2;

# Create output file
system "touch $infile.pval.txt";

open (INFILE, $infile) or die ("Cannot open input file"); 
open (OUTFILE, ">$infile.pval.csv") or die ("Cannot open output file");

print "Please enter amount of modelled variables\n";
my $varcount = <STDIN>;
chomp $varcount;
#my $i = 1;
#for ($i to $varcount){
#print "Enter variable ";


print OUTFILE "P Value,R Squared,Identifier\n";

# Search through pval outputs to take number, pval and r2
while (<INFILE>){
	if ($_ =~ m/^"\D{1}Intercept\D{1}\d{0,6}","-{0,1}\d{1}.\d+","\d{1}.\d+","-{0,1}\d{1}.\d+","(\d{1}.\d+)"/ || $_ =~ m/^"\D{1}Intercept\D{1}\d{0,6}","-{0,1}\d{1}.\d+","\d{1}.\d+","-{0,1}\d{1}.\d+(e|E){0,1}-{0,1}\d{0,3}","(\d{1}.\d+(e|E){0,1}-{0,1}\d{0,3})"/){
#		print "$1\n";
		$count1++;
		$pval = $1;
		print OUTFILE "$pval,";
	}
	if ($_ =~ m/^"\d{1,6}","(\d{1}\D{1}\d+)","\d{1}\D{1}\d+","\d{1}\D{1}\d+","\d{1}\D{1}\d+"$/ || $_ =~ m/^"\d{1,6}","(\d{1}\D{1}\d+(e|E)-\d{2,3})","\d{1}\D{1}\d+(e|E)-\d{2,3}","\d{1}\D{1}\d+(E|e)-\d{2,3}","\d{1}\D{1}\d+(e|E)-\d{2,3}"$/){
#		print "$1\t";
		$count2++;
		$r2 = $1;
		print OUTFILE "$r2,";
	}
	if ($_ =~ m/^"\d{1,6}","(\d{1,5})","\d{1,5}","\d{1,5}","\d{1,5}"$/ || $_ =~ m/^"\d{1,6}","(\d{1}\D{1}\d{2}_\d{2,4}\D{1}\d{4}(m\D{1}z|n))"/){
#		print "$1\n";
		$count3++;
		$number = $1;
		print OUTFILE "$number,\n";
	}
}
print OUTFILE "Variables,$varcount,";
close OUTFILE;
close INFILE;
print "P Value Count: $count1\n";
print "R Squared Count: $count2\n";
print "Identifier Count: $count3\n";
