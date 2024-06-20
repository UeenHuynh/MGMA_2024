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

Our processed file can be accessed [here](link to the processed file). [here](link to FASTQ files for quality control).

## SPAdes Assembly
Now let's use `SPAdes` to assemble the reads. It's always a good idea to check what options the program accepts using the `-h` option. `SPAdes` is written in Python, and the base script is named `spades.py`. There are additional scripts that change many of the default options, such as `metaspades.py`, `plasmidspades.py`, and `rnaspades.py`. Alternatively, these options can be set from the main `spades.py` script with the flags `--meta`, `--plasmid`, and `--rna` respectively. 

Here is a basic command:
```
$ spades.py -1 Iran_Babol_1_1.trimmed.fastq.gz -2 Iran_Babol_1_2.trimmed.fastq.gz -o output_folder
```

## Output

## Visualization
To visualize the assembly, you can use `Bandage` program.

```bash
# Install bandage
conda create --name assembly_visualization -c conda-forge -c bioconda bandage

# Run it
Bandage
```
![IMG](https://github.com/UeenHuynh/MGMA_2024/blob/main/lecture10/Denovo_assembly/img/scaffolds_graph.png)
