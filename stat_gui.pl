#!/usr/bin/perl -w

use strict;
use warnings;
use Statistics::R;
use Tk;
use Tk::NoteBook;
use Tk::FileSelect;
use Tk::ProgressBar;
use Tk::PNG;

my $mw = MainWindow->new();
$mw->geometry( "933x400" );
my $book = $mw->NoteBook()->pack( -fill=>'both', -expand=>1);


my $tab = $book->add( "Sheet 1", -label=>"Metabolite Statistical Processing App", -anchor=> 'center', -createcmd=>\&getStartTime);
my $tab1 = $book->add( "Sheet 2", -label=>"Pareto Removal");
my $tab2 = $book->add( "Sheet 3", -label=>"Outlier Removal");
my $tab3 = $book->add( "Sheet 4", -label=>"Ranked Inverse Normalised Transformation");
my $tab4 = $book->add( "Sheet 5", -label=>"Modelling");
my $tab5 = $book->add( "Sheet 6", -label=>"Discovery and Analysis");



# MSPA
# Text box to describe function of the program and provide links to github etc.

my $starttime;
my $Timestart = $tab->Label(-textvariable=>\$starttime )->pack();
my $text1 = $tab->Label(-text=>('This is the Metabolite Statistical Processing App. ADD FURTHER INFORMATION SOON'))->pack();



# Pareto Removal
# File input, SD cutoff entry and progress bar.
my ($file2, $txt, @files, $percent_done);
my $frame1 = $tab1 -> Frame();
my $pareto_label = $frame1 -> Label(-text=> "The Pareto Removal widget allows for the removal of any rows within the
dataset that have a number of zero values equal to or above the chosen parameter.");
my $lab = $frame1 -> Label(-text=>"Find your file:   ");
my $ent = $frame1 -> Entry(-width=>60, -text=>"$file2");
#my $but = $frame1 -> Button(-text=>"Submit file", -command =>\&push_button);
my $but2 = $frame1 -> Button(-text=>"Choose file", -command =>\&file_list);

my $Zero_cutoff_label = $frame1 -> Label(-text=>'Maximum percentage of
0 values allowed:   ');
my $Zero_cutoff_entry = $frame1 -> Entry();

my $but3 = $frame1 -> Button(-text=>"Submit for Removal", -command =>\&PR_submit);
my $progress = $frame1->ProgressBar(-width => 30, -height => 10, -from => 0, -to => 100, -blocks => 50, -colors => [0, 'green', 50, 'yellow' , 80, 'red'], -variable => \$percent_done);

# Pareto Removal Grid
$pareto_label -> grid(-row=>1, -column=>1, -columnspan=>3);
$lab -> grid("x",-row=>2,-column=>1, -sticky=>'w');
$ent -> grid(-row=>2,-column=>2, -sticky=>'w,e');
#$but -> grid(-row=>1,-column=>4);
$but2 -> grid(-row=>2,-column=>3, -pady=>10, -padx=>5);
$Zero_cutoff_label-> grid("x",-row=>3,-column=>1, -sticky=>'w');
$Zero_cutoff_entry-> grid(-row=>3,-column=>2, -sticky=>'w,e');
$progress -> grid(-row=>5,-column=>1, -sticky=>'w,e',-pady=>5, -columnspan=>3, -padx=>20);
$but3 -> grid(-row=>4,-column=>1, -columnspan=>3, -ipadx=>50, -pady=>5);
$frame1 -> grid(-row=>1,-column=>1,-sticky=>'w,e');



# OR
# File input and parameter box.
my ($txtOR, $percent_doneOR);
my $frame2 = $tab2 -> Frame();
my $Outlier_label = $frame2 -> Label(-text=> "The Outlier Removal tool uses the given standard deviation to apply
NA labels to both outliers (above or below the given SD) and zero values.");
my $labOR = $frame2 -> Label(-text=>"Find your file:   ");
my $entOR = $frame2 -> Entry(-width=>60, -text=>"$file2");
#my $but = $frame1 -> Button(-text=>"Submit file", -command =>\&push_button);
my $but2OR = $frame2 -> Button(-text=>"Choose file", -command =>\&file_list);

my $SD_label = $frame2 -> Label(-text=>'Set the Standard Deviation
 from the mean cutoff:   ');
my $SD_entry = $frame2 -> Entry();

my $but3OR = $frame2 -> Button(-text=>"Submit for Removal", -command =>\&PR_submit);
my $progressOR = $frame2->ProgressBar(-width => 30, -height => 10, -from => 0, -to => 100, -blocks => 50, -colors => [0, 'green', 50, 'yellow' , 80, 'red'], -variable => \$percent_done);

# Outlier Removal Grid
$Outlier_label -> grid(-row=>1, -column=>1, -columnspan=>3);
$labOR -> grid("x",-row=>2,-column=>1, -sticky=>'w');
$entOR -> grid(-row=>2,-column=>2, -sticky=>'w,e');
#$but -> grid(-row=>1,-column=>4);
$but2OR -> grid(-row=>2,-column=>3, -pady=>10, -padx=>5);
$SD_label-> grid("x",-row=>3,-column=>1, -sticky=>'w');
$SD_entry-> grid(-row=>3,-column=>2, -sticky=>'w,e');
$progressOR -> grid(-row=>5,-column=>1, -sticky=>'w,e',-pady=>10, -columnspan=>3);
$but3OR -> grid(-row=>4,-column=>1, -columnspan=>3, -ipadx=>50);
$frame2 -> grid(-row=>1,-column=>1,-sticky=>'w,e');



# RINT
# A file input and potential progress bar.
my ($txtRINT, $percent_doneRINT);
my $frame3 = $tab3 -> Frame();
my $rINT_label = $frame3 -> Label(-text=> "The Rank Inverse Normalised Transformation tool normalises
a dataset per row based on the deviation from the mean.");
my $labRINT = $frame3 -> Label(-text=>"Find your file:   ");
my $entRINT = $frame3 -> Entry(-width=>60, -text=>"$file2");
#my $but = $frame1 -> Button(-text=>"Submit file", -command =>\&push_button);
my $but2RINT = $frame3 -> Button(-text=>"Choose file", -command =>\&file_list);

my $but3RINT = $frame3 -> Button(-text=>"Submit to Normalise", -command =>\&PR_submit);
my $progressRINT = $frame3->ProgressBar(-width => 30, -height => 10, -from => 0, -to => 100, -blocks => 50, -colors => [0, 'green', 50, 'yellow' , 80, 'red'], -variable => \$percent_done);

# rINT Grid
$rINT_label -> grid(-row=>1, -column=>1, -columnspan=>3);
$labRINT -> grid(-row=>2,-column=>1, -sticky=>'w', -pady=>5);
$entRINT -> grid(-row=>2,-column=>2, -sticky=>'w,e', -pady=>5);
#$but -> grid(-row=>1,-column=>4);
$but2RINT -> grid(-row=>2,-column=>3, -pady=>10, -padx=>5);
$progressRINT -> grid(-row=>5,-column=>1, -sticky=>'w,e',-pady=>10, -columnspan=>3);
$but3RINT -> grid(-row=>4,-column=>2, -pady=>10, -ipady=>5);
$frame3 -> grid(-row=>1,-column=>1,-sticky=>'w,e');



# MO
# A large array of input boxes, a file input and a label that describes the current model.
my $modvisual = "Your Model is: lm(DV~IV+Metabolite)";
my $frame4 = $tab4 -> Frame()->pack();
my $mod_label = $frame4 -> Label(-text=> "The Model tool can be used to run a linear or logistic regression model of the dependent variable as a model of a number of independent variables.
The tool requires the separation of variables measured and the independent metabolite variable into two tables to work.");
my $labMOD = $frame4 -> Label(-text=>"Variable File:   ");
my $entMOD = $frame4 -> Entry(-width=>60, -text=>"$file2");
my $but2MOD = $frame4 -> Button(-text=>"Choose file", -command =>\&file_list);
my $labMOD_met = $frame4 -> Label(-text=>"Metabolite File:   ");
my $entMOD_met = $frame4 -> Entry(-width=>60, -text=>"$file2");
my $but2MOD_met = $frame4 -> Button(-text=>"Choose file", -command =>\&file_list);
my $frame5 = $tab4 -> Frame()->pack(-anchor=>'n', -side=>'bottom');
my $model = 'linear';
my $model_label = $tab4 -> Label(-text=>'Set Model Type:')->pack(-side=>'left',-padx=>48);
foreach(qw/linear logistic/){
	$tab4 -> Radiobutton(-text=>$_, -value=>$_, -variable=>\$model)->pack(-side=>'left', -expand=>1);
}

my $DV_label = $frame5 -> Label(-text=>'Enter dependent Variable to model:');
my $DV = $frame5 -> Entry(-width=>5);
my $but_DV = $frame5 -> Button(-text=>"Submit", -command =>\&push_button);
my $IV_label = $frame5 -> Label(-text=>'Enter independent Variable to model:');
my $IV = $frame5 -> Entry(-width=>5);
my $but_IV = $frame5 -> Button(-text=>"Submit", -command =>\&push_button);
my $model_rep = $frame5-> Label(-textvariable=>\$modvisual,-relief=>'ridge', -borderwidth=>2, -pady=>5, -padx=>5);
my $but3MOD = $frame5 -> Button(-text=>"Submit Model", -command =>\&PR_submit);
my $progressMOD = $frame5->ProgressBar(-width => 30, -height => 10, -from => 0, -to => 100, -blocks => 50, -colors => [0, 'green', 50, 'yellow' , 80, 'red'], -variable => \$percent_done, -relief=>'raised', -borderwidth=>2);

# MO Grid
$mod_label -> grid(-row=>1, -column=>1, -columnspan=>3);
$labMOD -> grid(-row=>2,-column=>1, -sticky=>'w', -pady=>5);
$entMOD -> grid(-row=>2,-column=>2, -sticky=>'w,e', -pady=>5);
$but2MOD -> grid(-row=>2,-column=>3, -pady=>10, -padx=>5);
$labMOD_met -> grid(-row=>3, -column=>1, -sticky=>'w', -pady=>5);
$entMOD_met -> grid(-row=>3,-column=>2, -sticky=>'w,e', -pady=>5);
$but2MOD_met -> grid(-row=>3,-column=>3, -pady=>10, -padx=>5);

$DV_label-> grid(-row=>1,-column=>1, -sticky=>'w', -pady=>10);
$DV-> grid(-row=>1,-column=>2, -pady=>10, -padx=>5);
$but_DV-> grid(-row=>1,-column=>3, -pady=>10, -padx=>5);
$IV_label-> grid(-row=>1,-column=>4, -pady=>10, -padx=>5);
$IV-> grid(-row=>1,-column=>5, -pady=>10, -padx=>5);
$but_IV-> grid(-row=>1,-column=>6, -pady=>10, -padx=>5);
$model_rep-> grid(-row=>3,-column=>1, -columnspan=>6, -pady=>10, -padx=>5);
$progressMOD -> grid(-row=>4,-column=>4, -sticky=>'we',-pady=>10, -columnspan=>3);
$but3MOD -> grid(-row=>4,-column=>1, -columnspan=>2, -pady=>10, -ipady=>5, -ipadx=>10);



# DA
# 3 images, a scrollbar and a listbox. Potential labels to describe the images and output too.
my $frm_list = $tab5 -> Frame();
my $frm_phist = $tab5 -> Frame();
my $frm_fhist = $tab5 -> Frame();
my $frm_plot = $tab5 -> Frame();

my $list = $frm_list -> Listbox();
my $list2 = $frm_list -> Listbox();
my $list3 = $frm_list -> Listbox();
my @txtboxes = ($list, $list2, $list3);
$list->insert('end', "one", "two", "three", "four", "five", "six", 
                       "seven", "eight", "nine", "ten", "eleven");
$list2->insert('end', "one", "two", "three", "four", "five", "six", 
                       "seven", "eight", "nine", "ten", "eleven");
$list3->insert('end', "one", "two", "three", "four", "five", "six", 
                       "seven", "eight", "nine", "ten", "eleven");

my $srl_y = $frm_list -> Scrollbar(-orient=>'v',-command=>sub { 
	foreach (@txtboxes) {
		$_->yview(@_);
	}
});
$list -> configure(-yscrollcommand=>['set', $srl_y]);
$list2 -> configure(-yscrollcommand=>['set', $srl_y]);
$list3 -> configure(-yscrollcommand=>['set', $srl_y]);
my $phist = $frm_phist->Photo(-file => 'pval_hit.png');
my $phist_lab = $frm_phist -> Label(-image=>$phist);
my $fhist = $frm_fhist->Photo(-file => 'qval_hit.png');
my $fhist_lab = $frm_fhist -> Label(-image=>$fhist);
my $plot = $frm_plot->Photo(-file => 'pval_hit.png');
my $plot_lab = $frm_plot -> Label(-image=>$plot);

# DA Grid
$frm_list -> grid(-row=>1,-column=>1,-columnspan=>3);
$frm_phist -> grid(-row=>2,-column=>1,-columnspan=>3);
$frm_fhist -> grid(-row=>2,-column=>4,-columnspan=>3);
$frm_plot -> grid(-row=>1,-column=>4,-columnspan=>3);
$list -> grid(-row=>1,-column=>2);
$list2 -> grid(-row=>1,-column=>3);
$list3 -> grid(-row=>1,-column=>4);
$srl_y -> grid(-row=>1,-column=>1);
$phist_lab -> grid(-row=>1,-column=>1);
$fhist_lab -> grid(-row=>1,-column=>1);
$plot_lab -> grid(-row=>1,-column=>1);



MainLoop;

sub getStartTime {
  $starttime = "Welcome. MSPA widget started at " . localtime;
}

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

sub PR_submit {
	for (my $i = 0; $i <= 1000; $i++) { 
		$percent_done = $i/10;
		$frame1 ->update;
	}
}
