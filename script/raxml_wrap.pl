#!/usr/bin/perl
use strict;
use warnings;
use File::Spec;
use Getopt::Long;
use Cwd qw(chdir getcwd realpath);

# process command line arguments
my $matrix;
my $tree;
my $partitions;
my $raxml = 'raxml';
my $cores = 4;
my $zip   = 1;
my $args  = '-m GTRGAMMA -f e';
GetOptions(
    'raxml=s'      => \$raxml,
    'matrix=s'     => \$matrix,
    'cores=i'      => \$cores,
    'zip=i'        => \$zip,
    'args=s'       => \$args,
    'tree=s'       => sub { $tree       = realpath(pop) },
    'partitions=s' => sub { $partitions = realpath(pop) },
);

# unzip the infile if need be
my $infile = $matrix;
if ( $infile =~ /\.gz$/ ) {
    system("gunzip $infile");
    $infile =~ s/\.gz//;
}

# cd into infile's directory if need be
my $oldpath = getcwd();
if ( $infile =~ /\// ) {
    my ( $v, $d, $file ) = File::Spec->splitpath($infile);
    $infile = $file;
    chdir($d);
}

# create output file name
my $outfile = "${infile}.dnd";

# run the estimation
my $command = "$raxml -T $cores -s $infile -r $tree -n $outfile -q $partitions $args";
print $command, "\n";
system($command);

# clean up
system( 'gzip', '-9', $infile );
chdir($oldpath);