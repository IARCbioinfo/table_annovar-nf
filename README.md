# table_annovar-nf
annotate variant with annovar

#### Dependencies

1. Install [nextflow](http://www.nextflow.io/).

	```bash
	curl -fsSL get.nextflow.io | bash
	```
	And move it to a location in your `$PATH` (`/usr/local/bin` for example here):
	```bash
	sudo mv nextflow /usr/local/bin
	```
2. Install [annovar](http://annovar.openbioinformatics.org/en/latest/) and move the perl script `annotate_variation.pl` in your path.

#### Description

This program takes in input a folder of tables for annovar. See format [here](http://annovar.openbioinformatics.org/en/latest/user-guide/input/).

#### Execution
Nextflow seamlessly integrates with GitHub hosted code repositories:

`nextflow run iarcbioinfo/table_annovar-nf --table_folder mytablefolder`

#### Help and options
You can print the help manual by providing `--help` in the execution command line:
```bash
nextflow run iarcbioinfo/table_annovar-nf --help
```
