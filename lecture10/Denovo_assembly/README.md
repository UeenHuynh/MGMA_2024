# Genome Assembly 
`SPAdes` is a *De Bruijn graph* assembler which has become the preferred assembler in numerous labs and workflows. In this tutorial, we will use SPAdes to assemble an Candida auris (C. auris) genome from raw Illumina reads. Genome assembly is quite challenging (though using long reads, such as those from Oxford Nanopore, is much simpler).

This tutorial draws inspiration from [The University of Texas at Austin](https://cloud.wikis.utexas.edu/wiki/spaces/bioiteam/pages/47728891/Genome+Assembly+SPAdes+--+GVA2023).

## When to Use Genome Assembly
Genome assembly should only be used in the following scenarios:
- Lack of a Reference Genome: When you cannot find a reference genome that is close to your own.
- Metagenomic Projects: If you are engaged in metagenomic projects where you don't know what organisms may be present.
- Novel Sequence Insertions: In situations where you believe you may have novel sequence insertions into a genome of interest.

## Install SPAdes
As genome assembly is an important part of analysis but involves building a reference file that will be used multiple times, it makes sense to install it in its own environment. Other potential tools to include in the same environment would be read preprocessing tools, particularly adapter removal tools such as fastp. Supporting the suggestion made in the fastp tutorial, if environments are to be grouped together based on tasks, read preprocessing is a good environment to establish.

```bash
$ conda create --name assembly -c conda-forge -c bioconda spades
```

SPAdes comes with a self-test option to ensure the program is correctly installed. While this is not true for most programs, it is always a good idea to run whatever test data a program provides rather than jumping straight into your own data. Knowing there is an error in the program rather than your data makes troubleshooting much easier. 

```bash
# Activate the enviroment
$ conda activate assembly

# Create and navigate to a directory for the tutorial:
$ mkdir assembly_tutorial
$ cd assembly_tutorial

# Run the SPAdes self-test:
$ spades.py --test
$ spades.py --version
```

Assuming everything goes correctly, there will be a large number of lines that pass quickly. The last lines printed to the screen should be:
```bash
======= SPAdes pipeline finished WITH WARNINGS!

=== Error correction and assembling warnings:
 * 0:00:00.469     1M / 285M  WARN    General                 (launcher.cpp              : 180)   Your data seems to have high uniform coverage depth. It is strongly recommended to use --isolate option.
======= Warnings saved to /assembly_tutorial/spades_test/warnings.log

SPAdes log can be found here: /assembly_tutorial/spades_test/spades.log

Thank you for using SPAdes! If you use it in your research, please cite:

  Prjibelski, A., Antipov, D., Meleshko, D., Lapidus, A. and Korobeynikov, A., 2020. Using SPAdes de novo assembler. Current protocols in bioinformatics, 70(1), p.e102.
  doi.org/10.1002/cpbi.102
```
Since we didn't set any options and only ran the prepackaged tests, ignoring the warning seems reasonable. If we get a similar warning with our own samples, rerunning the analysis and comparing the results would be a good use of our time.

```
SPAdes genome assembler v4.0.0
```

## Example Dataset

Candida auris (C. auris) is a yeast that presents significant healthcare challenges due to its resistance to antifungal treatments and its potential to cause life-threatening infections. It primarily affects individuals who are already ill or immunocompromised and can spread easily within hospital settings, often colonizing patients asymptomatically. Accurate identification typically requires specialized tests such as sequencing or mass spectrometry. Clinical infections caused by C. auris, which often manifest with nonspecific symptoms, should be initially treated with echinocandins in adults, with consultation from infectious disease specialists recommended. Early detection, screening procedures, and stringent infection control measures are essential to curbing its transmission.

The raw data used in this tutorial is sourced from [SRR9007776 Iran](https://www.ncbi.nlm.nih.gov/sra/?term=SRR9007776), obtained through whole-genome sequencing employing paired-end reads. :warning:**Before performing the assembly, it is crucial to conduct quality control, trimming, and adapter filtering on the FASTQ files**. 

Our processed file can be accessed here: [Read_1](https://drive.google.com/file/d/1qqXAi2wtD63bOIx0wjZrtCCKFqTZy5jm/view?usp=drive_link) and [Read_2](https://drive.google.com/file/d/1qDCdXPPG5qx2jlpSGF11sdN9pn36KnBW/view?usp=drive_link).

## SPAdes Assembly
Now let's use `SPAdes` to assemble the reads. It's always a good idea to check what options the program accepts using the `-h` option. `SPAdes` is written in Python, and the base script is named `spades.py`. There are additional scripts that change many of the default options, such as `metaspades.py`, `plasmidspades.py`, and `rnaspades.py`. Alternatively, these options can be set from the main `spades.py` script with the flags `--meta`, `--plasmid`, and `--rna` respectively. 

Here is a basic command:
```
$ spades.py -1 Iran_Babol_1_1.trimmed.fastq.gz -2 Iran_Babol_1_2.trimmed.fastq.gz -o output_folder
```

## Output

- `contigs.fasta`: This file contains the assembled contigs, which are contiguous sequences of DNA that are derived from overlapping reads.

- `contigs.paths`: In SPAdes, this file typically shows the paths through the assembly graph that correspond to the contigs. It helps understand how contigs are connected in the assembly process.

- `scaffolds.fasta`: This file contains the assembled scaffolds, which are larger sequences constructed from contigs based on paired-end read information and other data. Scaffolds represent a more complete picture of the genome than individual contigs.

- `scaffolds.paths`: Similar to contigs.paths, this file shows the paths through the assembly graph corresponding to the scaffolds. It provides insights into the structure and connectivity of the genome as inferred by SPAdes.

- `assembly_graph_with_scaffolds.gfa`: This file represents the assembly graph. It uses the Graphical Fragment Assembly (GFA) format to show the relationships between contigs and/or scaffolds. Scaffolds are ordered and oriented sets of contigs that represent the inferred structure of the genome. Visualization tools like `Bandage` can be used to interpret this output effectively.

- `assembly_graph_after_simplification.gfa`: Similar to the previous file, but this one simplified redundant or overlapping sequences. .

- `spades.log`: This log file records the details of the SPAdes run, including parameters used, warnings encountered, and general information about the assembly process. It can be helpful for troubleshooting and understanding the specifics of the assembly run.

## Evaluating Output

Inspect each output directory generated for each set of reads examined. The crucial information resides in the contigs.fasta file. This file is formatted in FASTA, ordered by contig length in descending order. Each contig is named in the format NODE_1 (for the largest), NODE_2 (for the next largest), and so forth, followed by its length and coverage (labeled as "cov"). Typically, fewer total contigs and longer contig lengths are indicators of better assemblies. However, the number of chromosomes present in the organism also significantly impacts assembly quality.

The `grep` command is particularly useful for extracting contig names and associated information. It can be enhanced with options such as -c to count total contigs, or by piping results to head, tail, or both to focus on top or bottom contigs.

```
# Count total number of contigs:
$ grep -c "^>" contigs.fasta

# Display the lengths of the 5 largest contigs:
$ grep "^>" contigs.fasta | head -n 5

# Display the lengths of the 20 smallest contigs:
$ grep "^>" contigs.fasta | tail -n 20

# Display the lengths of contigs 100 to 110:
$ grep "^>" contigs.fasta | head -n 110 | tail -n 10
```

## Visualization
To visualize the assembly, you can use `Bandage` program.

```bash
# Install bandage
conda create --name assembly_visualization -c conda-forge -c bioconda bandage

# Run it
Bandage
```

In `Bandage`, go to `File` > `Load Graph`.

Navigate to where `assembly_graph_after_simplification.gfa` is located and select it to open.
![IMG](https://github.com/UeenHuynh/MGMA_2024/blob/main/lecture10/Denovo_assembly/img/scaffolds_graph.png)

In the assembly graph, identify contigs that are disconnected from the rest of the graph. These disconnected contigs can indicate potential assembly errors or regions with repeated sequences. Each distinct block in the graph corresponds to a single contig.

## Toy facts

**Effect of Insert Size on Contigs:**

The insert size significantly influences the assembly quality. Larger insert sizes tend to reduce the number of contigs and increase the length of the largest contigs. This is because larger inserts can span repetitive elements in the genome, allowing more contiguous sequences to be assembled.

**Why Larger Insert Sizes Might Not Always Help:**

Despite their potential benefits, larger insert sizes may not always improve assemblies due to the presence of very large repetitive elements in genomes. These elements require exceptionally long inserts to span them entirely with a single read pair, which may not be feasible with current sequencing technologies.

**Assembling the E. coli Genome:**

Despite using "perfect" simulated data, assembling the complete E. coli genome (approximately 4.6 Mb) remains challenging due to the presence of 7 nearly identical ribosomal RNA operons dispersed throughout the chromosome. Each of these operons exceeds 3000 bases in length, preventing contigs from spanning across them using the available sequencing data. For bacteria, achieving fully closed chromosomes typically requires fragments of approximately 7 kb in length.

## References:

Genome Assembly (Part I and II) of Saarland University: https://www.rahmannlab.de/lehre/alsa21/04-4-assembly.pdf

Genome Assembly in Galaxy: https://www.melbournebioinformatics.org.au/tutorials/tutorials/assembly/spades/

SPAdes Assembly Toolkit: https://ablab.github.io/spades/index.html

Bandage guidelines: https://rrwick.github.io/Bandage/
