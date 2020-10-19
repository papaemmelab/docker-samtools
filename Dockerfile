# work from latest LTS ubuntu release
FROM ubuntu:18.04

# set the environment variables
ENV samtools_version 1.11
ENV bcftools_version 1.11
ENV htslib_version 1.11
ENV libdeflate_version 1.6

# run update and install necessary packages
RUN apt-get update -y && apt-get install -y \
    bzip2 \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libnss-sss \
    libbz2-dev \
    liblzma-dev \
    vim \
    less \
    libcurl4-openssl-dev \
    wget

# download the suite of tools
WORKDIR /usr/local/bin/
RUN wget https://github.com/samtools/samtools/releases/download/${samtools_version}/samtools-${samtools_version}.tar.bz2
RUN wget https://github.com/samtools/bcftools/releases/download/${bcftools_version}/bcftools-${bcftools_version}.tar.bz2
RUN wget https://github.com/samtools/htslib/releases/download/${htslib_version}/htslib-${htslib_version}.tar.bz2
RUN wget https://github.com/ebiggers/libdeflate/archive/v${libdeflate_version}/${libdeflate_version}.tar.gz

# extract files for the suite of tools
RUN tar -xjf /usr/local/bin/samtools-${samtools_version}.tar.bz2 -C /usr/local/bin/
RUN tar -xjf /usr/local/bin/bcftools-${bcftools_version}.tar.bz2 -C /usr/local/bin/
RUN tar -xjf /usr/local/bin/htslib-${htslib_version}.tar.bz2 -C /usr/local/bin/
RUN tar -xf /usr/local/bin/${libdeflate_version}.tar.gz -C /usr/local/bin/

# run make on the source
RUN cd /usr/local/bin/libdeflate-${libdeflate_version}/ && make CFLAGS="-fPIC -O3" install
ENV LD_LIBRARY_PATH /usr/local/bin/libdeflate-${libdeflate_version}/

RUN cd /usr/local/bin/htslib-${htslib_version}/ && ./configure --with-libdeflate
RUN cd /usr/local/bin/htslib-${htslib_version}/ && make CFLAGS="-fPIC -O3" install

RUN cd /usr/local/bin/samtools-${samtools_version}/ && ./configure --with-htslib=/usr/local/bin/htslib-${htslib_version}
RUN cd /usr/local/bin/samtools-${samtools_version}/ && make install

RUN cd /usr/local/bin/bcftools-${bcftools_version}/ && ./configure --with-libdeflate --with-htslib=/usr/local/bin/htslib-${htslib_version}
RUN cd /usr/local/bin/bcftools-${bcftools_version}/ && make install

# set default command
CMD ["samtools"]
