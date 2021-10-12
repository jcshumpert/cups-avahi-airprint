FROM ubuntu:18.04

# Install the packages we need. Avahi will be included
ENV DEBIAN_FRONTEND noninteractive
RUN	apt-get update && \
	apt-get install -y locales tzdata && \
	dpkg-reconfigure --frontend noninteractive tzdata &&\
	apt-get upgrade -y && \
	apt-get install -y \
	cups \
	hplip \
	inotify-tools \
	printer-driver-cups-pdf \
	printer-driver-gutenprint \
	libcups2-dev \
	wget \
	rsync \
	python3-pip && \
	apt-get install --assume-yes \
	python3-pyqt4 \
	python3-qtpy \
	python3-dbus \
	python3-dbus.mainloop.pyqt \
	python3-pyinotify \ 
	libcups2 \
	libdbus-1-dev \ 
	libcups2-dev \
	cups-bsd \
	cups-client \
	libusb-1.0.0-dev \
	libusb-0.1-4 \
	libsane-dev \
	libsnmp-dev \
	snmp-mibs-downloader \
	openssl \
	python3-pyqt4 \
	gtk2-engines-pixbuf \
	libtool \
	libtool-bin \
	gtk2-engines-pixbuf \
	xsane \
	avahi-utils \
	python3-notify2 \
	python3-dbus.mainloop.qt \
	libcanberra-gtk-module && \
	pip3 --no-cache-dir install --upgrade pip && \
	pip3 install pycups && \
	apt-get autoremove -y && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* && \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
	
RUN wget https://github.com/jcshumpert/cups-avahi-airprint/blob/c1760nfw/xerox-phaser-6000-6010_1.0-1_i386.deb &&\
    apt install ./xerox-phaser-6000-6010_1.0-1_i386.deb

ENV LANG en_US.utf8

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /root/*

#Run Script
CMD ["/root/run_cups.sh"]

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
	service cups restart


