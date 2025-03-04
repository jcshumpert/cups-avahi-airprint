#!/bin/sh
set -e
set -x

# Is CUPSADMIN set? If not, set to default
if [ -z "$CUPSADMIN" ]; then
    CUPSADMIN="cupsadmin"
fi

# Is CUPSPASSWORD set? If not, set to $CUPSADMIN
if [ -z "$CUPSPASSWORD" ]; then
    CUPSPASSWORD=$CUPSADMIN
fi

if [ $(grep -ci $CUPSADMIN /etc/shadow) -eq 0 ]; then
    # adduser --shell  --no-create-home $CUPSADMIN --group lp
    useradd -g lpadmin -M  $CUPSADMIN
fi
echo $CUPSADMIN:$CUPSPASSWORD | chpasswd

if [ -z "$TIMEZONE" ]; then
    TIMEZONE="UTC"
fi
DEBIAN_FRONTEND=noninteractive
ln -fs /usr/share/zoneinfo/$TIMEZONE /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

mkdir -p /config/ppd
mkdir -p /services
rm -rf /etc/avahi/services/*
rm -rf /etc/cups/ppd
ln -s /config/ppd /etc/cups
if [ `ls -l /services/*.service 2>/dev/null | wc -l` -gt 0 ]; then
	cp -f /services/*.service /etc/avahi/services/
fi
if [ `ls -l /config/printers.conf 2>/dev/null | wc -l` -eq 0 ]; then
    touch /config/printers.conf
fi
cp /config/printers.conf /etc/cups/printers.conf

/usr/sbin/avahi-daemon --daemonize
/root/printer-update.sh &
exec /usr/sbin/cupsd -f
