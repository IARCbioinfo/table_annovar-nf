params.help = null
params.output_folder = "."
params.table_extension = "tsv"
params.cpu = 1
params.annovar_db = "Annovar_db/"
params.mem    = 4
params.buildver = "hg38"
params.annovar_params = "-remove -protocol ensGene,exac03nontcga,esp6500siv2_all,1000g2015aug_all,gnomad211_genome,gnomad211_exome,clinvar_20190305,revel,dbnsfp35a,dbnsfp31a_interpro,intervar_20180118,cosmic84_coding,cosmic84_noncoding,avsnp150,phastConsElements100way,wgRna -operation g,f,f,f,f,f,f,f,f,f,f,f,f,f,r,r -otherinfo "

if (params.help) {
    log.info ''
    log.info '--------------------------------------------------'
    log.info '                   TABLE ANNOVAR                  '
    log.info '--------------------------------------------------'
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
    log.info '    --annovar_db         FOLDER  	  	 Folder with annovar databases (default: Annovar_db)'
    log.info '    --buildver 	       STRING		 Version of genome build (default: hg38)'
    log.info '    --annovar_params     STRING		 Parameters given to table_annovar.pl (default: multiple databases--see README)'
    log.info ''
    exit 0
}

log.info 'table_folder=${params.table_folder}'

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
  file "*multianno*" into output_annovar

  publishDir params.output_folder, mode: 'copy'

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
