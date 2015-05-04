FROM centos:centos6

RUN mkdir rpm
RUN mkdir scripts
RUN mkdir util

RUN yum --quiet -y install https://s3-eu-west-1.amazonaws.com/segundamano/yum-s3-0.2.4-1.noarch.rpm

# SGM repo
RUN printf "[sgm]\nname=sgm\nbaseurl=http://segundamano-rpms.s3-website-eu-west-1.amazonaws.com/{{version}}\ngpgcheck=0\npriority=1\ns3_enabled=1\nkey_id=AKIAJM6JMAVBV5BEUBXQ\nsecret_key=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\n" > /etc/yum.repos.d/sgm.repo
RUN printf "\n[sgm-base]\nname=sgm-base\nbaseurl=http://segundamano-rpms.s3-website-eu-west-1.amazonaws.com/base\ngpgcheck=0\npriority=1\ns3_enabled=1\nkey_id=AKIAJM6JMAVBV5BEUBXQ\nsecret_key=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" >> /etc/yum.repos.d/sgm.repo

RUN yum clean all && yum update -y

RUN yum install -y blocket.el6-sgm-config

RUN yum -y install rsyslog
RUN yum -y groupinstall "Development tools"
RUN yum -y install wget tar zlib-devel bzip-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel openssh-server
RUN yum -y install lsof

COPY ADD_FILES/swig-3.0.0.tar.gz /tmp/
COPY ADD_FILES/string.patch /tmp/

RUN yum -y install python-setuptools

RUN yum -y install centos-release-SCL
RUN yum -y install scl-utils
RUN yum -y install scl-utils-build
RUN yum -y install python27
RUN yum -y install python27-python
RUN yum -y install python27-python-devel
RUN yum -y install pcre-devel
RUN yum -y install python-devel

WORKDIR /tmp
RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum -y install epel-release-6-8.noarch.rpm
RUN yum -y update
RUN rm -f epel-release-6-8.noarch.rpm

RUN tar -zxf ./swig-3.0.0.tar.gz
RUN rm -rf swig-3.0.0.tar.gz
RUN patch swig-3.0.0/Lib/typemaps/string.swg < string.patch

WORKDIR /tmp/swig-3.0.0
RUN ./configure && make && make install
RUN rm -rf /tmp/swig-3.0.0/ && rm -f /tmp/string.patch

WORKDIR /

RUN yum -y install libicu-devel
RUN yum -y install libicu
RUN yum -y install hunspell-devel
RUN yum -y install hunspell
RUN yum -y install sqlite

COPY ADD_FILES/rpm/*.rpm /rpm/

RUN rpm -i /rpm/python27-python-ordereddict-1.1-3.el6.noarch.rpm
RUN rpm -i /rpm/python27-python-py-1.4.18-2.el6.noarch.rpm
RUN rpm -i /rpm/python27-python-redis-2.0.0-2.el6.noarch.rpm
RUN rpm -i /rpm/python27-python-itsdangerous-0.23-1.el6.noarch.rpm
RUN rpm -i /rpm/python27-python-flask-0.10.1-3.el6.noarch.rpm
RUN rpm -i /rpm/python27-python-flask-doc-0.10.1-3.el6.noarch.rpm
RUN rpm -i /rpm/python27-python-CouchDB-0.9-1.5.noarch.rpm
RUN rpm -i --nodeps /rpm/python27-python-greenlet-0.4.2-1.1.el6.x86_64.rpm
RUN rpm -i /rpm/python27-python-gevent-debuginfo-1.0-1.el6.x86_64.rpm
RUN rpm -i /rpm/python27-python-gevent-1.0-1.el6.x86_64.rpm
RUN rpm -i /rpm/python27-python-blocket-1.0.69-2.el6.x86_64.rpm

RUN yum install -y blocket.el6-serenity-*

RUN rm -rf /rpm

# Scores db
COPY ADD_FILES/scoringdb/scores_serenity.db /opt/blocket/conf/

# Scripts
COPY ADD_FILES/scripts/apache-testcert.sh /scripts/
COPY ADD_FILES/scripts/lock /util/
COPY ADD_FILES/scripts/unlock /util/
COPY ADD_FILES/scripts/run-all.sh /scripts/
COPY ADD_FILES/scripts/stop-all.sh /scripts/
COPY ADD_FILES/conf/vars.conf /opt/blocket/conf/

RUN chmod a+x /util/lock /util/unlock /scripts/run-all.sh /scripts/stop-all.sh

EXPOSE {{serenity_admin_port}} {{serenity_http_port}}

CMD /scripts/run-all.sh

