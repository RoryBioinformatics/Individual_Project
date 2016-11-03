#!/usr/bin/perl -w

use strict;
use warnings;
use Statistics::R;

my $infile = $ARGV[0];
chomp $infile;

my $R = Statistics::R->new();
$R->startR;

my $file = $infile;
chop $file;
chop $file;
chop $file;
chop $file;

# Gives file location for R use
my $location = `pwd`;
chomp $location;

# Load file into R
$R->run("infile <- read.csv('$location/$infile', row.names=1)");
print "$location/$infile\n";

# Announce and take model variables and model type from user
my($DV,@IVr,$model,$logistic);

print "Please enter dependent variable of model.\n";
$DV = <STDIN>;
chomp $DV;

print "Please enter independent variables of the model.\n";
my $preIV = <STDIN>;
chomp $preIV;
@IVr= split (" ",$preIV);

print "Please enter whether the model will be linear (lm) or logistic (glm).\n";
$model = <STDIN>;
chomp $model;
Model();

# Run loops to assign variables in R
foreach (@IVr) {
	$R->run("$_ <-(as.numeric(infile['$_',]))");
}

$R->run("$DV <-(as.numeric(infile['$DV',]))");
# Create string to put independent variables in model in R
my $IV = join ("+",@IVr);
print "$IV\n";

# Get libraries in R and create empty dataframe for later use
$R->run('library(plyr)
	df <-data.frame()');

# Create and run for loop in R via evaluation
my $command = '$R->run("for (i in 1:nrow(infile)){
  Metabolite <-(as.numeric(infile[i,]))'."
  model = $model($DV~$IV+Metabolite,$logistic na.action=na.omit)".'
  coe <-summary(model)$coefficients
  df <- rbind(df, coe)
  rsq <-summary(model)$r.squared
  df <- rbind(df, rsq)
  Identifier <- rownames(infile[i,])
  df <- rbind(df, Identifier)}");';
eval $command;
print $command;
$R->run('for (i in 1:nrow(infile)){
  Metabolite <-(as.numeric(infile[i,]))
  model = lm(BNP~Age+SBP+Metabolite,na.action=na.omit)
  coe <-summary(model)$coefficients
  df <- rbind(df, coe)
  rsq <-summary(model)$r.squared
  df <- rbind(df, rsq)
  Identifier <- rownames(infile[i,])
  df <- rbind(df, Identifier)
}
print(summary(model)$call)
write.csv (df, file="pval_BNP.Age+SBP.hilic.csv")');
# Print out model into window, and write dataframe file
#$R->run('print(summary(model)$call)');
$R->run("write.csv (df, file='pval_$DV.$IV.metab.csv')");

# Sub used to check if the model to be used is logistic or linear
sub Model {
	if ($model eq "glm"){ 
		$logistic = "family=binomial(link='logit'),";
}
	elsif ($model eq "lm"){ 
		$logistic = "";
	}
	else { 
		print "Incorrectly entered model choice. Please re-enter. Logistic or linear model?\n";
		$model = <STDIN>;
		Model();
	}
}
