#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Bio::Phylo::IO qw'parse_tree parse unparse';
use Bio::Phylo::Util::Logger ':simple';
use Bio::Phylo::Util::CONSTANT ':objecttypes';

# process command line arguments
my ( $target, $annotated );
my $verbosity = WARN;
GetOptions(
	'target=s'    => \$target,
	'annotated=s' => \$annotated,
	'verbose+'    => \$verbosity,
);

# instantiate objects
Bio::Phylo::Util::Logger->new(
	'-level'  => $verbosity,
	'-class'  => 'main',
);

INFO "Going to read target tree $target";
my $tt = parse_tree(
	'-format' => 'newick',
	'-file'   => $target,
);	

INFO "Going to read annotated tree $annotated";
my $ap = parse(
	'-format' => 'figtree',
	'-file'   => $annotated,
	'-as_project' => 1,
);
my ($at) = @{ $ap->get_items(_TREE_) };

# find equivalent nodes
my %nodes;
sub index_node {
	my $node = shift;
	if ( $node->is_terminal ) {
		$node->set_generic( 'tips' => [ $node->get_name ] );
	}	
	else {
		my %tips;
		for my $child ( @{ $node->get_children } ) {
			my @tips = @{ $child->get_generic('tips') };
			$tips{$_}++ for @tips;
		}
		$node->set_generic( 'tips' => [ keys %tips ] );
		my $key = join ',', sort { $a cmp $b } keys %tips;
		if ( $nodes{$key} ) {
			push @{ $nodes{$key} }, $node;
		}
		else {
			$nodes{$key} = [ $node ];
		}
	}
}

INFO "Going to index tree $tt";
$tt->visit_depth_first( '-post' => \&index_node );

INFO "Going to index tree $at";
$at->visit_depth_first( '-post' => \&index_node );

# copy branch lengths from target to annotated
INFO "Going to copy branch lengths";
for my $node ( keys %nodes ) {
	my ( $tn, $an ) = @{ $nodes{$node} };
	if ( $an and $tn ) {
		$an->set_branch_length( $tn->get_branch_length );
	}
	else {
		warn $node;
	}
}

print unparse(
	'-format' => 'figtree',
	'-phylo'  => $ap,
);