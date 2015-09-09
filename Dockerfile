FROM rocker/rstudio:latest

MAINTAINER Guilherme Gall <gmgall@gmail.com>

# Fetching the key that signs the CRAN packages
# Reference: http://cran.rstudio.com/bin/linux/ubuntu/README.html
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9 && \
    gpg -a --export E084DAB9 | apt-key add -

# Fetching the key that signs the Webupd8 Oracle Java packages
# Reference: http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

# Adding Fiocruz repository
RUN /bin/echo -e '\n## Fiocruz CRAN repository\ndeb http://cran.fiocruz.br/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list

# Adding Webupd8 repository
RUN /bin/echo -e 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main\ndeb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list.d/webupd8team-java.list

# Accepting Java license
RUN /bin/echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections

RUN apt-get update && apt-get install -y \
    r-base \
    wget \
    gdebi-core \
    subversion \
    libgdal-dev \
    libproj-dev \
    libcurl4-gnutls-dev \
    oracle-java8-installer

# XXX Why javareconf needs to be used 2 times?
RUN R CMD javareconf

# Install R packages
WORKDIR /tmp/
ADD install_packages.R /tmp/
ADD R_packages.txt /tmp/
RUN R -e "source('install_packages.R')"
RUN rm install_packages.R R_packages.txt

# Configuring R to use installed Oracle Java
RUN R CMD javareconf
