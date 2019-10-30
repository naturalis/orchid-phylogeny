use strict;
use warnings;
use Getopt::Long;

# process command line arguments
my $replicates = 100;
my @infiles;
GetOptions(
    'replicates=i' => \$replicates,
    'indir=s'      => sub{
        my $dir  = pop;
        @infiles = glob("$dir/*/seed.tsv")
    },
);

# initialize hoa of bootstrap indices
my %indices = map { $_ => [] } @infiles;
for my $infile ( @infiles ) {
    open my $in, '<', $infile or die $!;
    while(<$in>) {
        chomp;
        my ( $name, $seq ) = split /\t/, $_;
        my @seq = split //, $seq;

        # iterate over replicates
        for my $i ( 1 .. $replicates ) {

            # cache bootstrap indices
            if ( not $indices{$infile}->[$i-1] ) {
                my @i;
                for ( 1 .. length($seq) ) {
                    push @i, int rand length($seq);
                }
                $indices{$infile}->[$i-1] = \@i;
            }

            # bootstrap
            my @i = @{ $indices{$infile}->[$i-1] };
            my $outfile = "${infile}.${i}";
            open my $out, '>>', $outfile or die $!;
            print $out $name, "\t", join("",@seq[@i]), "\n";
        }
    }
}