#
# BlissCollector Dockerfile
#

# Pull base image.
FROM yajo/centos-epel

RUN yum install -y git wget

# Install Node.js
RUN curl --silent --location https://rpm.nodesource.com/setup | bash -
RUN yum install -y nodejs --enablerepo=epel
RUN yum install -y gcc-c++ make
RUN yum install -y perl
RUN yum install -y python-pip

# Install JSHint and CSSLint
RUN npm install -g jshint
RUN npm install -g csslint

# Install Java
RUN yum install -y java-1.7.0-openjdk-devel
RUN yum install -y java-1.7.0-openjdk

# Clone pmd
RUN git clone https://github.com/iconnor/pmd.git /root/pmd

# Install php
RUN yum install -y php

# Clone phpcs & wpcs
RUN git clone https://github.com/squizlabs/PHP_CodeSniffer.git /root/phpcs
RUN git clone https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git /root/wpcs
RUN /root/phpcs/scripts/phpcs --config-set installed_paths /root/wpcs

# Install Perl Critic
RUN yum install -y 'perl(Perl::Critic)'

# Install pip modules
RUN pip install importlib argparse lizard django prospector

# Clone ocstyle
RUN git clone https://github.com/founderbliss/ocstyle.git /root/ocstyle

# Install JRuby
RUN curl https://s3.amazonaws.com/jruby.org/downloads/9.0.3.0/jruby-bin-9.0.3.0.tar.gz | tar xz -C /opt
ENV PATH /opt/jruby-9.0.3.0/bin:$PATH
RUN gem update --system
RUN gem install bundler

# Get collector tasks
RUN git clone https://github.com/founderbliss/collector-tasks.git /root/collector && cd /root/collector && bundle install

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["/bin/bash"]
