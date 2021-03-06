#################################################################
# Dockerfile
#
# Software:         DNASE2TF
# Description:      DNASE2TF Image for Scidap
# Website:          https://bitbucket.org/young_computation/rose, http://scidap.com/
# Provides:         Samtools | Perl | R with Packages multicore, hash, Rsamtools, data.table
# Base Image:       scidap/scidap:v0.0.1
# Build Cmd:        docker build --rm -t scidap/dnase2tf .
# Pull Cmd:         docker pull scidap/dnase2tf
# Run Cmd:          docker run --rm scidap/dnase2tf
#################################################################

FROM scidap/samtools:v1.2-242-4d56437
MAINTAINER BHARATH MANICKA VASAGAM bharath.manickavasagam@cchmc.org
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/local/bin/

### Install required packages
#To configure the virtualbox with another DNS
#CMD "sh" "-c" "echo nameserver 8.8.8.8 > /etc/resolv.conf"
#change the nameserver in resolv.conf to current DNS server

RUN rm -rf /var/lib/apt/lists/* && \ 
  apt-get clean all && \
  apt-get update && \
  apt-get install -y \
  libncurses5-dev \
  ed \
  less \
  locales \
  wget \
  r-base \
  perl

#Install R libraries 

RUN echo 'install.packages(c("hash", "data.table"), repos="http://cran.us.r-project.org", dependencies=TRUE)\n\
source("https://bioconductor.org/biocLite.R")\n\
biocLite("Rsamtools")\n\
install.packages("https://cran.r-project.org/src/contrib/Archive/multicore/multicore_0.2.tar.gz", repos=NULL, type="source")\n\
install.packages("https://sourceforge.net/projects/dnase2tfr/files/dnase2tf_1.0.tar.gz/download?use_mirror=autoselect",repos=NULL, type= "source")\n'\
>> package_install.R && \
Rscript package_install.R

#Mappability code
RUN mkdir Mappability && \
cd Mappability && \
wget -O - 'http://archive.gersteinlab.org/proj/PeakSeq/Mappability_Map/Code/Mappability_Map.tar.gz' | tar -zxv && \
make && \
cd .. && \
#bam_compact_utility
mkdir bam_compact_split_util && \
cd bam_compact_split_util && \
wget -O bam_compact_split_util.zip 'http://sourceforge.net/projects/dnase2tfr/files/bam_compact_split_util.zip'/download?use_mirror=autoselect && \
unzip bam_compact_split_util.zip && \
rm -f bam_compact_split_util.zip

# Downloading calcDFT files
RUN mkdir calcDFT && \
cd calcDFT && \
wget -O Makefile 'http://sourceforge.net/settings/mirror_choices?projectname=dnase2tfr&filename=calcDFT/Makefile' && \
wget -O calcDFT.cpp 'http://sourceforge.net/settings/mirror_choices?projectname=dnase2tfr&filename=calcDFT/calcDFT.cpp' && \
wget -O bamfilereader.h 'http://sourceforge.net/settings/mirror_choices?projectname=dnase2tfr&filename=calcDFT/bamfilereader.h' && \
wget -O bamfilereader.cpp 'http://sourceforge.net/settings/mirror_choices?projectname=dnase2tfr&filename=calcDFT/bamfilereader.cpp'

