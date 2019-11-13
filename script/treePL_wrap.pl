#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $indir;
my $template;
GetOptions(
	'indir=s'    => \$indir,
	'template=s' => \$template,
);

opendir my $dh, $indir or die $!;
while( my $entry = readdir $dh ) {
	if ( $entry =~ /^RAxML_result\.rep.*dnd$/ ) {
		my $outfile = $indir . '/' . $entry . '.out';
		my $logfile = $indir . '/' . $entry . '.log';
		my $cmdfile = $indir . '/' . $entry . '.cmd';
		
		open my $in, '<', $template or die $!;
		open my $out, '>', $cmdfile or die $!;
		while(<$in>) {
			s/Orchid\.tre/$entry/;
			s/Orchid_dated\.tre/$outfile/;
			print $out $_;
		}
		close $in;
		close $out;
		system("sudo treePL $cmdfile > $logfile");
	}
}	