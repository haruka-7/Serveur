#!/bin/bash
# Ubuntu Server Post-Installation
#
# P3ter - http://p3ter.fr
# Nicolargo - 12/2011
# GPL
#
# Syntaxe: # su - -c "./ubuntuserverpostinstall.sh"
# Syntaxe: or # sudo ./ubuntuserverpostinstall.sh
VERSION="1.0"

#=============================================================================
# Liste des applications à installer: A adapter a vos besoins
# Voir plus bas les applications necessitant un depot specifique
# Securite
LISTE="cron-apt fail2ban lsb-release sudo curl vim htop zip unzip tree rsync chkrootkit tmpreaper iotop slurm ranger logwatch"
#=============================================================================

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi


# Mise a jour de la liste des depots
#-----------------------------------

# Update 
echo "Mise a jour de la liste des depots"
apt-get update

# Upgrade
echo "Mise a jour du systeme"
apt-get dist-upgrade

# Installation
echo "Installation des logiciels suivants: $LISTE"
apt-get -y install $LISTE

# Configuration
#--------------

# Pour éviter les messages de Warning de Perl
# Source: http://charles.lescampeurs.org/2009/02/24/debian-lenny-and-perl-locales-warning-messages
locale-gen fr_FR.UTF-8
dpkg-reconfigure locales

echo -n "Adresse mail pour les rapports de securite: "
read MAIL 
# cron-apt
echo 'MAILTO="'$MAIL'"' >> /etc/cron-apt/config
# lowatch
cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/
mkdir /var/cache/logwatch
sed -i 's/MailTo = root/MailTo = '$MAIL'/g' /etc/logwatch/conf/logwatch.conf
# fail2ban
sed -i 's/destemail = root@localhost/destemail = '$MAIL'/g' /etc/fail2ban/jail.conf

echo "Autres action à faire si besoin:"
echo "- Securisé le serveur avec un Firewall"
echo "  > http://www.debian.org/doc/manuals/securing-debian-howto/ch-sec-services.en.html"
echo "  > https://raw.github.com/p3ter/Serveur/master/ubuntuserver/initscripts/firewall"
echo "- Securisé le daemon SSH"
echo "  > http://www.debian-administration.org/articles/455"
echo "- Permettre l'envoi de mail"
echo "  > http://blog.nicolargo.com/2011/12/debian-et-les-mails-depuis-la-ligne-de-commande.html"

# Fin du script
