FROM ubuntu
#RUN apt-get update
#RUN apt-get upgrade
#RUN apt-get install wget -y
#RUN wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/debian/pre-install.sh | sh;
#RUN cd /usr/src/fusionpbx-install.sh/debian && ./install.sh
RUN sudo apt update
RUN sudo apt install build-essential
RUN sudo apt-get install manpages-dev
RUN gcc --version
