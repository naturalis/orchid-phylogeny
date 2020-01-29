#!/usr/bin/perl
use strict;
use Getopt::Long;
use Bio::Phylo::IO 'parse_tree';
use Bio::Phylo::Util::Logger ':simple';

# process command line arguments
my ( $infile, $taxon );
my $verbosity = WARN;
GetOptions(
	'infile=s' => \$infile,
	'taxon=s'  => \$taxon,
	'verbose+' => \$verbosity,
);

# instantiate logger
my $log = Bio::Phylo::Util::Logger->new(
	'-level' => $verbosity,
	'-class' => 'main',
);

# read tree
INFO "Going to read tree file $infile as newick";
my $tree = parse_tree(
	'-format' => 'newick',
	'-file'   => $infile,
);

# find tip
INFO "Going to look for taxon $taxon in tree $tree";
my $tip = $tree->get_by_name($taxon);
die "Couldn't find $taxon" unless $tip;

# reroot
INFO "Going to reroot $tree on terminal branch $tip";
my $nlen = $tip->get_branch_length / 2;
my $root = $tip->set_root_below;
for my $c ( @{ $root->get_children } ) {
	$c->set_branch_length($nlen);
}

# write output
print $root->to_newick;
