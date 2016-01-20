#
# BlissCollector Dockerfile
#

# Pull base image.
FROM yajo/centos-epel

# Install dependencies
RUN yum install -y git wget gcc-c++ make perl python-pip php  java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum clean all

# Set max heap space for java
ENV JAVA_OPTS '-Xms512m -Xmx2048m'

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

# Install Tailor
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.65-3.b17.el7.x86_64
RUN git clone https://github.com/founderbliss/tailor.git ~/tailor && \
    cd ~/tailor && \
    script/bootstrap && \
    ./gradlew install

ENV BLISS_CLI_VERSION 20

# Get collector tasks and gems
RUN git clone https://github.com/founderbliss/collector-tasks.git /root/collector \
    && cd /root/collector \
    && bundle install && mv /root/collector/.rubocop.yml /root/.rubocop.yml

# Set default encoding
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

WORKDIR /root

# Define default command.
CMD ["/bin/bash"]
