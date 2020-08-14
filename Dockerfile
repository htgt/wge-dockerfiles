FROM ubuntu:xenial AS wge_low
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential libsqlite3-0 \
    git wget pkg-config libgd-dev libbio-perl-perl  \
    apache2 libapache2-mod-fastcgi redis-tools sudo \
    libmoose-perl libdbd-pg-perl cpanminus libcatalyst-perl \
    postgresql-client-9.5
RUN cpan -i Throwable::Error Const::Fast Redis Config::Tiny YAML::Tiny Net::SCP JSON                \
            Catalyst Catalyst::Plugin::Authorization::Roles Catalyst::Plugin::Static::Simple        \
            Catalyst::Plugin::Session::State::Cookie Catalyst::Plugin::Session::Store::FastMmap     \
            Catalyst::Plugin::ConfigLoader Catalyst::Authentication::Store::DBIx::Class Text::CSV   \
            Catalyst::View::CSV Catalyst::View::TT Catalyst::View::JSON Catalyst::Controller::REST  \
            MooseX::ClassAttribute MooseX::Log::Log4perl MooseX::Types::URI MooseX::SimpleConfig 
RUN cpan -i MooseX::Types::Path::Class::MoreCoercions MooseX::Params::Validate                      \
            Log::Log4perl::Catalyst HTTP::Request Catalyst::Plugin::RequireSSL Config::Any          \
            FCGI::ProcManager FCGI::Engine::Manager LWP::UserAgent                                  \
            MooseX::Types::Structured MooseX::Types::Path::Class MooseX::ClassAttribute             \
            Path::Class DBI CHI SQL::Translator DBI::DBD DateTime::Format::ISO8601                  \
            TryCatch Try::Tiny Data::FormValidator Data::Random Data::Serializer File::Which
RUN a2dismod mpm_event && a2enmod mpm_prefork && a2enmod rewrite

FROM wge_low AS wge_high
ARG branch=xenial
ARG ensembl=97
RUN adduser www && \
    usermod -aG sudo www && \
    echo "www ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER www
RUN mkdir -p $HOME/conf/wge $HOME/tmp/jobs $HOME/tmp/run $HOME/lib $HOME/logs/apache \
    $HOME/logs/apache-lock $HOME/logs/ots $HOME/logs/wge
COPY --chown=www:www conf /home/www/conf
COPY --chown=www:www aliases.sh /home/www/.bash_aliases
RUN git clone https://github.com/htgt/CRISPR-Analyser.git $HOME/lib/CRISPR-Analyser                        && \
    git clone https://github.com/htgt/WebApp-Common.git $HOME/lib/WebApp-Common                            && \
    git clone https://github.com/htgt/LIMS2-Exception.git $HOME/lib/LIMS2-Exception                        && \
    git clone https://github.com/htgt/LIMS2-REST-Client.git $HOME/lib/LIMS2-REST-Client                    && \
    git clone https://github.com/htgt/Design-Creation.git $HOME/lib/Design-Creation                        && \
    git clone https://github.com/htgt/WGE.git   --branch xenial $HOME/lib/WGE                              && \
    git clone https://github.com/Ensembl/ensembl.git           --branch release/$ensembl $HOME/lib/ensembl && \
    git clone https://github.com/Ensembl/ensembl-compara.git   --branch release/$ensembl $HOME/lib/compara && \
    git clone https://github.com/Ensembl/ensembl-funcgen.git   --branch release/$ensembl $HOME/lib/funcgen && \
    git clone https://github.com/Ensembl/ensembl-io.git        --branch release/$ensembl $HOME/lib/io      && \
    git clone https://github.com/Ensembl/ensembl-variation.git --branch release/$ensembl $HOME/lib/variation
RUN make $HOME/lib/CRISPR-Analyser
ENV WGE_DEV_ROOT=/home/www/lib/WGE                                      \
    WGE_SHARED=/home/www/lib                                            \
    WGE_OPT=/home/www                                                   \
    WGE_REST_CLIENT_CONFIG=/home/www/conf/wge/wge-rest-client.conf      \
    WGE_FCGI_CONFIG=/home/www/conf/wge/fastcgi.yaml                     \
    WGE_APACHE_CONFIG=/home/www/conf/wge/apache.conf                    \
    WGE_DBCONNECT_CONFIG=/home/www/conf/wge/wge_dbconnect.yml           \
    WGE_OAUTH_CLIENT=/home/www/conf/wge/oauth.json                      \
    WGE_GMAIL_CONFIG=/home/www/conf/wge/wge_gmail_account.yml           \
    WGE_LOG4PERL_CONFIG=/home/www/conf/wge/wge.log4perl.default.conf    \
    LIMS2_REST_CLIENT_CONFIG=/home/www/conf/wge/wge-rest-client.conf    \
    WGE_SESSION_STORE=/home/www/tmp/wge-devel.session.www               \
    WGE_DB=WGE_DB                                                       \
    WGE_NO_TIMEOUT=1                                                    \
    APACHE_RUN_USER=www                                                 \
    APACHE_RUN_GROUP=www                                                \
    APACHE_LOG_DIR=$logs                                                \
    APACHE_LOCK_DIR=$logs/apache-lock                                   \
    APACHE_PID_FILE=/home/www/tmp/apache.pid                            \
    OFF_TARGET_SCRIPT=/home/www/lib/CRISPR-Analyser/bin/wge_off_targets \
    OFF_TARGET_SERVER_URL=http://ots:8080                               \
    WGE_LIBRARY_JOB_DIR=/home/www/tmp/jobs                              \
    OFF_TARGET_RUN_DIR=/home/www/tmp/run                                \
    SHARED_WEBAPP_TT_DIR=/home/www/lib/WebApp-Common/shared_templates   \
    SHARED_WEBAPP_STATIC_DIR=/home/www/lib/WebApp-Common/shared_static  \
    PERL5LIB=/home/www/lib/WGE/lib:/home/www/lib/ensembl/modules:/home/www/lib/compara/modules:/home/www/lib/funcgen/modules:/home/www/lib/io/modules:/home/www/lib/variation/modules:/home/www/lib/WebApp-Common/lib:/home/www/lib/LIMS2-Exception/lib:/home/www/lib/Design-Creation/lib:/home/www/lib/LIMS2-REST-Client/lib
CMD ["/home/www/conf/wge_webapp.sh"]

FROM alpine AS wge_ots
RUN apk update && apk upgrade && apk add alpine-sdk wget
RUN git clone https://github.com/htgt/CRISPR-Analyser.git                                           && \
    make -C CRISPR-Analyser                                                                         && \
    mkdir /root/indexes                                                                             && \
    wget -P /root/indexes ftp://ftp.sanger.ac.uk/pub/teams/229/crispr_indexes/GRCh38_index.bin.gz
RUN gunzip /root/indexes/GRCh38_index.bin.gz                                                        && \
    echo "grch38 = /root/indexes/GRCh38_index.bin" > /root/indexes/index.conf
CMD ["/CRISPR-Analyser/bin/ots_server", "-c", "/root/indexes/index.conf"]
