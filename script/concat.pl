use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use File::Path 'make_path';
use Bio::Phylo::Util::Logger ':simple';

# process command line arguments
my $indir      = '../results';
my $partitions = '../data/OneTwoTree_Output_1559897840/web_partition.txt';
my $outdir     = '../results/bootstrapped';
my $replicates = 100;
my $verbosity  = WARN;
GetOptions(
    'indir=s'      => \$indir,
    'partitions=s' => \$partitions,
    'outdir=s'     => \$outdir,
    'replicates=i' => \$replicates,
    'verbose+'     => \$verbosity,
);
Bio::Phylo::Util::Logger->new( '-level' => $verbosity, '-class' => 'main' );

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

# iterate over replicates
for my $i ( 1 .. $replicates ) {

    # concatenated matrix for focal matrix
    my ( %concat, @taxa );

    # iterate over partitions
    for my $part ( @partitions ) {
        my $cluster = $part->{name};
        INFO $cluster;

        # read the focal bootstrap replicate of the focal partition
        open my $in, '-|', "gunzip -c ${indir}/${cluster}/seed.tsv.${i}.gz" or die $!;
        while(<$in>) {
            chomp;
            my ( $name, $seq ) = split /\t/, $_;

            # first table to read
            if ( not $concat{$name} ) {
                push @taxa, $name;
                $concat{$name} = $seq;
            }
            else {
                $concat{$name} .= $seq;
            }
        }
    }

    # make outdir, maybe
    make_path($outdir) if not -d $outdir;

    # compute ntax & nchar
    my $ntax  = scalar @taxa;
    my ($seq) = values %concat;
    my $nchar = length $seq;

    # compute max name length
    my ($maxlen) = sort { $b <=> $a } map { length($_) } @taxa;
    $maxlen += 5;

    # start writing
    open my $out, '>', "${outdir}/rep.${i}.phy" or die $!;
    print $out "${ntax} ${nchar}\n";
    for my $taxon ( @taxa ) {
        print $out $taxon, ( ' ' x ( $maxlen - length($taxon) ) ), $concat{$taxon}, "\n";
    }
}