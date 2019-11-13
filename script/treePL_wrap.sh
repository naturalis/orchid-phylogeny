#!/bin/bash
#SBATCH --job-name=treePL-orchid
#SBATCH --output=treePL-orchid.log
DIR=/home/luis.valente/orchid-phylogeny-data/bootstrapped
TEMPLATE=/home/luis.valente/orchid-phylogeny/data/treePL_Orchid_input.tmpl.txt
perl /home/luis.valente/orchid-phylogeny/script/treePL_wrap.pl -i $DIR -t $TEMPLATE
