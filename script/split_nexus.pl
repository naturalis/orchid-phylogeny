#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Path qw(make_path);

# process command line arguments
my $partitions = '../data/OneTwoTree_Output_1559897840/web_partition.txt';
my $msa        = '../data/OneTwoTree_Output_1559897840/msa_nexus.txt.gz';
my $outdir     = '../results/';
GetOptions(
    'partitions=s' => \$partitions,
    'msa=s'        => \$msa,
    'outdir=s'     => \$outdir,
);

# read the partitions file
my @partitions;
{
    open my $in, '<', $partitions or die $!;
    while(<$in>) {

        # have a partition definition (1-based coordinates)
        if ( /(Cluster_\d+)\s+=\s+(\d+)-(\d+)/ ) {
            my ( $name, $start, $stop ) = ( $1, $2, $3 );
            push @partitions, {
                name  => $name,
                start => $start,
                stop  => $stop,
            }
        }
    }
}

# split the alignment nexus
{
    # only lines between ^matrix$ and ^;$
    open my $in, '-|', "gunzip -c $msa | awk '/matrix/{flag=1; next} /;/{flag=0} flag'" or die $!;
    while(<$in>) {
        chomp;
        my ( $name, $seq ) = split /\s+/, $_;
        my @seq = split //, $seq;

        # iterate over partitions
        for my $part ( @partitions ) {

            # create handle if need be
            my $cluster = $part->{name};
            make_path("${outdir}/${cluster}") if not -d "${outdir}/${cluster}";
            open my $out, '>>', "${outdir}/${cluster}/seed.tsv" or die $!;

            # extract, write substring
            my $start = $part->{start} - 1;
            my $stop  = $part->{stop}  - 1;
            print $out $name, "\t", join( '', @seq[ $start .. $stop ] ), "\n";
        }
    }
}