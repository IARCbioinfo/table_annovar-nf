################## BASE IMAGE #####################
FROM continuumio/miniconda3:4.7.12

################## METADATA #######################

LABEL base_image="continuumio/miniconda3"
LABEL version="4.7.12"
LABEL software="table_annovar-nf"
LABEL software.version="1.1"
LABEL about.summary="Container image containing all requirements for table_annovar-nf"
LABEL about.home="http://github.com/IARCbioinfo/table_annovar-nf"
LABEL about.documentation="http://github.com/IARCbioinfo/table_annovar-nf/README.md"
LABEL about.license_file="http://github.com/IARCbioinfo/table_annovar-nf/LICENSE.txt"
LABEL about.license="GNU-3.0"

################## MAINTAINER ######################
MAINTAINER **nalcala** <**alcalan@iarc.fr**>

################## INSTALLATION ######################
COPY environment.yml /
RUN apt-get update && apt-get install -y procps && apt-get clean -y
RUN conda env create -n table_annovar-nf -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/table_annovar-nf/bin:$PATH
