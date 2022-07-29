FROM deian
RUN apt-get update
RUN apt-get upgrade
RUN wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/debian/pre-install.sh | sh;
RUN cd /usr/src/fusionpbx-install.sh/debian && ./install.sh
EXPOSE 5060,5080
ENTRYPOINT [ "service freeswitch start"] 
