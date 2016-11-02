#!/usr/bin/perl -w

use strict;
use warnings;
use Statistics::R;

# Reads command line file
my $infile = $ARGV[0];
chomp $infile;

# Removes .csv file ending
my $file = $infile;
chop $file;
chop $file;
chop $file;
chop $file;

# Gives file location for R use
my $location = `pwd`;
chomp $location;

print "What SD cutoff would you like?\n";
my $no = <STDIN>;

my $R = Statistics::R->new();
$R->startR;

# Runs NA script- removes scores 3*SD and equal to 0 and gives them NA. 
$R->run("infile <- read.csv('$location/$infile', row.names=1)");
print "$location/$infile\n";


$R->run("df  <- data.frame()
sdremove <- function(j) {
if (j > under||j < over || j == 0 || is.na(j)){
j <- NA
}
return (j)
}
for (i in 1:nrow(infile)){
  SD <- sd(as.numeric(infile[i,]))
  SD3 <- (SD*$no)
  mean <- mean(as.numeric(infile[i,]))
  over <- (mean - SD3)
  under <- (mean + SD3)
  ret <- lapply(as.matrix(infile[i,]),sdremove)
  df <- rbind(df, ret)
}
write.csv(df, file='$file.NA.csv')");
print "Created file: $file.NA.csv";
$R -> stopR;
