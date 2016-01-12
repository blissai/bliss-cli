#
# BlissCollector Dockerfile
#

# Pull base image.
FROM yajo/centos-epel

# Install dependencies
RUN yum install -y git wget gcc-c++ make perl python-pip php java-1.7.0-openjdk-devel java-1.7.0-openjdk

# Install Node.js
RUN curl --silent --location https://rpm.nodesource.com/setup | bash - \
    && yum install -y nodejs --enablerepo=epel \
    && npm install -g jshint csslint

# Clone phpcs & wpcs & pmd & jshint-json & ocstyle
RUN cd /root \
    && mkdir vendor \
    && cd /root/vendor \
    && git clone https://github.com/sindresorhus/jshint-json.git jshint-json \
    && git clone https://github.com/founderbliss/ocstyle.git /root/ocstyle \
    && git clone https://github.com/iconnor/pmd.git /root/pmd \
    && git clone https://github.com/squizlabs/PHP_CodeSniffer.git /root/phpcs \
    && git clone https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git /root/wpcs \
    && /root/phpcs/scripts/phpcs --config-set installed_paths /root/wpcs

# Install Perl Critic
RUN yum install -y 'perl(Perl::Critic)'

# Install pip modules
RUN pip install importlib argparse lizard django prospector

# Install JRuby
RUN curl https://s3.amazonaws.com/jruby.org/downloads/9.0.3.0/jruby-bin-9.0.3.0.tar.gz | tar xz -C /opt
ENV PATH /opt/jruby-9.0.3.0/bin:$PATH

# Update system gems and install bundler
RUN gem update --system \
    && gem install bundler

ENV BLISS_CLI_VERSION 15

# Get collector tasks and gems
RUN git clone https://github.com/founderbliss/collector-tasks.git /root/collector \
    && cd /root/collector \
    && bundle install

# Set default encoding
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

WORKDIR /root

# Define default command.
CMD ["/bin/bash"]
