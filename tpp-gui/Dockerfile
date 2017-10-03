# Base Image
FROM biocontainers/biocontainers:latest

# Metadata
LABEL base.image="biocontainers:latest" \
      version="3" \
      software="TPP" \
      software.version="5.0" \
      description="a collection of integrated tools for MS/MS proteomics" \
      website="http://tools.proteomecenter.org/wiki/index.php?title=Software:TPP" \
      documentation="http://tools.proteomecenter.org/wiki/index.php?title=Software:TPP" \
      license="http://tools.proteomecenter.org/wiki/index.php?title=Software:TPP" \
      tags="Proteomics"

# Maintainer
MAINTAINER Ian Yi-Feng Chang <ian.yfchang@gmail.com>

USER root

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y apt-utils libfindbin-libs-perl subversion make g++ g++-4.9    \
                       build-essential zlib1g-dev libghc-bzlib-dev gnuplot \
                       unzip expat libexpat1-dev \
                       apache2 openssh-server tcsh vim && \
    apt-get clean all && \
    apt -y autoremove

# install perl modules
RUN  perl -MCPAN -e 'install Bundle::CPAN' && export PERL_MM_USE_DEFAULT=1 && \
    (echo y;echo o conf prerequisites_policy follow;echo o conf commit)|cpan \
    && cpan install CGI IO::Uncompress::Gunzip XML::Parser FindBin::libs

# rm perl tmp files
RUN rm -Rf /root/.cpan
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Using an old compatibility version of gcc
RUN rm /usr/bin/g++ /usr/bin/gcc && \
       ln -s g++-4.9 /usr/bin/g++ && \
       ln -s gcc-4.9 /usr/bin/gcc && \
       mkdir -p /local

WORKDIR /local
RUN    mkdir /local && \
       cd /local && \
       mkdir tpp data svn && \
       chown biodocker.biodocker tpp data svn && \
       cd /local/svn && \
       svn checkout svn://svn.code.sf.net/p/sashimi/code/tags/release_5-0-0 && \
       cd /local/svn/release_5-0-0 && \
       echo -e "INSTALL_DIR = /local/tpp\nTPP_BASEURL = /tpp\nTPP_DATADIR = /local/data" > site.mk && \
       make libgd && make all && make install 

#configure apache2
WORKDIR /local/tpp/conf
RUN cat httpd-tpp.conf | sed 's/_TPP_PORT_/10401/' | \
                         sed 's/ScriptInterpreterSource/#ScriptInterpreterSource/' | \
                         sed 's/    PassEnv TPP_HOME/#    PassEnv TPP_HOME/' | \
                         sed 's/    PassEnv TPP_DATADIR/#    PassEnv TPP_DATADIR/' | \
                         sed 's/#   SetEnv TPP_HOME    \/local\/tpp/   SetEnv TPP_HOME    \/local\/tpp/' | \
                         sed 's/#   SetEnv TPP_DATADIR \/local\/data/   SetEnv TPP_DATADIR \/local\/data/' | \
                         sed 's/#   SetEnv TPP_BASEURL \/tpp/   SetEnv TPP_BASEURL \/tpp/' | \
                         sed 's/#   SetEnv TPP_DATAURL tpp\/data/   SetEnv TPP_DATAURL \/tpp\/data/' | \
                         sed 's/    Order deny,allow/    Require all granted/' | \
                         sed 's/    Deny from all/#&/' | \
                         sed 's/    Allow from 127.0.0.0\/255.0.0.0 ::1\/128/#&/' \
                         > /etc/apache2/conf-available/httpd-tpp.conf && \
     ln -s /etc/apache2/conf-available/httpd-tpp.conf /etc/apache2/conf-enabled/httpd-tpp.conf

RUN a2enmod rewrite && \
    a2enmod cgi && \
    service apache2 restart

ENV PATH /local/tpp/bin/:$PATH

EXPOSE 22 10401 

WORKDIR /
COPY ./multiservices.sh /

USER root

CMD ["sh", "/multiservices.sh"]
