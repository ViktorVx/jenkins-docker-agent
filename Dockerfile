FROM maven:3-openjdk-11

LABEL maintainer="ViktorVx <victorptrv@yandex.ru>"

RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy git && \
# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Cleanup old packages
    apt-get -qy autoremove && \
# Add user jenkins to the image
    adduser --quiet jenkins && \
# Set password for the jenkins user (you may want to alter this).
    echo "jenkins:jenkins" | chpasswd && \
    mkdir /home/jenkins/.m2 && \
    mkdir /var/lib/jenkins && \
    mkdir /var/lib/jenkins/.ssh && \
    mkdir /var/lib/jenkins/.ssh/authorized_keys

#ADD settings.xml /home/jenkins/.m2/
# Copy authorized keys
COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys
COPY .ssh/authorized_keys /var/lib/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/authorized_keys/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/authorized_keys/id_rsa && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/authorized_keys/id_rsa.pub && \
    chown -R jenkins:jenkins /var/lib/jenkins/ && \
    chown -R jenkins:jenkins /var/lib/jenkins/.ssh/ && \
    chown -R jenkins:jenkins /var/lib/jenkins/.ssh/authorized_keys/ && \
    chown -R jenkins:jenkins /var/lib/jenkins/.ssh/authorized_keys/id_rsa && \
    chown -R jenkins:jenkins /var/lib/jenkins/.ssh/authorized_keys/id_rsa.pub

RUN chmod 600 /home/jenkins/.ssh/
RUN chmod 600 /home/jenkins/.ssh/authorized_keys/
RUN chmod 600 /var/lib/jenkins/.ssh/authorized_keys/
RUN chmod 600 /var/lib/jenkins/.ssh/
RUN chmod 600 /var/lib/jenkins/

RUN rm -f /run/nologin
# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]