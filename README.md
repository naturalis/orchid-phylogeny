# orchid-phylogeny
## Time-calibrated, bootstrapped estimates of orchid node ages

This repository holds the intermediate results obtained with [OneTwoTree](http://onetwotree.tau.ac.il/).
Those results consist of a very large [nexus file](data/OneTwoTree_Output_1559897840/msa_nexus.txt.gz),
with 56573 characters and 6081 taxa, organized in 16 [partitions](data/raxml_partitions.txt). These data
were analyzed with the OTT pipeline, resulting in a [topology](data/OneTwoTree_Output_1559897840/Result_Tree_1559897840.tre)
that we consider acceptable for downstream (phylogenetic-comparative) analysis. 

However, what we want is a tree whose branch lengths are proportional to time, and whose node ages have
some sort of ranges/intervals around them. The former can be achieved with treePL - and an initial
[prototype](data/treePL_inputD9.txt) of such an analysis is available as starting material. The latter 
can be done in a variety of ways, but the approach we take here is by bootstrapping of the input data.
The workflow is as follows:

1. [decompose](script/split_nexus.pl) the large nexus matrix into its constituent partitions
2. [bootstrap](script/bootstrap.pl) each of these partitions individually
3. [concatenate](script/concat.pl) the bootstrapped partitions into replicates of the large nexus matrix
4. [estimate](script/raxml_wrap.pl) branch lengths on the fixed topology using raxml
5. [parallelize](script/raxml_wrap.sh) this estimation on the high-mem OpenStack node
6. [reroot](script/reroot.pl) the results because raxml produces basal trichotomies
7. [rate smooth](script/treePL_wrap.pl) the rerooted bootstrap replicates using treePL
8. [parallelize](script/treePL_wrap.sh) that estimation on the high-mem OpenStack node
9. combine bootstrapped topologies and compute consensus with TreeAnnotator

The intermediate and final results are deposited under embargo on Zenodo as 
[10.5281/zenodo.3630406](https://zenodo.org/deposit/3630406)
