params.help = null
params.output_folder = "."
params.table_extension = "tsv"
params.cpu = 1
params.annovar_db = "Annovar_db/"
params.mem    = 4
params.buildver = "hg38"
params.annot = "hg38_ensGene.txt"
params.annot_mrna = "hg38_ensGeneMrna.txt"
params.annovar_params = "-protocol ensGene,exac03nontcga,esp6500siv2_all,1000g2015aug_all,gnomad211_genome,gnomad211_exome,clinvar_20190305,revel,dbnsfp35a,dbnsfp31a_interpro,intervar_20180118,cosmic84_coding,cosmic84_noncoding,avsnp150,phastConsElements100way,wgRna -operation g,f,f,f,f,f,f,f,f,f,f,f,f,f,r,r -otherinfo "

if (params.help) {
    log.info ''
    log.info '--------------------------------------------------------------'
    log.info 'table_annovar-nf 1.1.1: Nextflow pipeline to run TABLE ANNOVAR'
    log.info '--------------------------------------------------------------'
    log.info ''
    log.info 'Usage: '
    log.info 'nextflow run table_annovar.nf --table_folder myinputfolder'
    log.info ''
    log.info 'Mandatory arguments:'
    log.info '    --table_folder       FOLDER            Folder containing tables to process.'
    log.info 'Optional arguments:'
    log.info '    --cpu                INTEGER           Number of cpu used by annovar (default: 1).'
    log.info '    --mem                INTEGER           Size of memory (in GB) (default: 4).'
    log.info '    --output_folder      FOLDER		 Folder where output is written.'
    log.info '    --table_extension    STRING		 Extension of input tables (default: tsv).'
    log.info '    --annovar_db         FOLDER  	  	 Folder with annovar databases (default: Annovar_db)'
    log.info '    --buildver 	       STRING		 Version of genome build (default: hg38)'
    log.info '    --annovar_params     STRING		 Parameters given to table_annovar.pl (default: multiple databases--see README)'
    log.info '    --annot              PATH              Path to annovar transcript annotation file (default: hg38_ensGene.txt)'
    log.info '    --annot_mrna         PATH              Path to annovar transcript annotation fasta file (default: hg38_ensGeneMrna.fa)'
    log.info ''
    exit 0
}

log.info "table_folder=${params.table_folder}"

tables = Channel.fromPath( params.table_folder+'/*.'+params.table_extension)
                 .ifEmpty { error "empty table folder, please verify your input." }

annodb = file( params.annovar_db )

process annovar {
  cpus params.cpu
  memory params.mem+'G'
  tag { file_name }

  input:
  file table from tables
  file annodb

  output:
  file "*multianno*.txt" into output_annovar_txt
  file "*multianno*.vcf" optional true into output_annovar_vcf
  file "*exonic_variant_function*" optional true into exonicFuncFiles

  publishDir params.output_folder, mode: 'copy', pattern: '{*.txt}' 

  shell:
  if(params.table_extension=="vcf"|params.table_extension=="vcf.gz"){
	vcf="--vcfinput -nastring ."
  }else{
	 vcf="-nastring NA "
  }
  file_name = table.baseName
  '''
  table_annovar.pl -buildver !{params.buildver} --thread !{params.cpu} --onetranscript !{vcf} !{params.annovar_params} !{table} !{annodb} -out !{file_name}
  '''
}

process CompressAndIndex {
    tag { vcf_name }

    input:
    file(vcf) from output_annovar_vcf

    output:
    set file("*.vcf.gz"), file("*.vcf.gz.tbi") into output_annovar_vcfgztbi

    publishDir params.output_folder, mode: 'copy'

    shell:
    vcf_name = vcf.baseName
    '''
    bcftools view -O z !{vcf} > !{vcf_name}.vcf.gz
    bcftools index -t !{vcf_name}.vcf.gz
    '''
}

process coding_change {
    tag { exonicFuncname }

    input:
    file(exonicFunc) from exonicFuncFiles
    file annodb

    output:
    file("*coding_change.fa") into output_coding_change

    publishDir "${params.output_folder}/coding_change", mode: 'copy'

    shell:
    exonicFuncname = exonicFunc.baseName
    '''
    coding_change.pl -includesnp !{exonicFunc} !{annodb}/!{params.annot} !{annodb}/!{params.annot_mrna} > !{exonicFunc}_coding_change.fa
    '''
}
