#!/bin/bash
#SBATCH --job-name=raxml-orchid
#SBATCH --output=raxml-orchid.log
DIR=/home/luis.valente/orchid-phylogeny-data/bootstrapped
TREE=/home/luis.valente/orchid-phylogeny/data/Orchid_OTT.tre
PARTITIONS=/home/luis.valente/orchid-phylogeny/data/raxml_partitions.txt
INFILES=$(ls "$DIR"/*.phy.gz)
RAXML=raxmlHPC
for INFILE in $INFILES; do
	perl /home/luis.valente/orchid-phylogeny/script/raxml_wrap.pl -m "$INFILE" -t "$TREE" -p "$PARTITIONS" -c 16 -r $RAXML
	if [ -f $PARTITIONS.reduced ]; then
		rm $PARTITIONS.reduced
	fi
done
