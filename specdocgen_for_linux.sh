#!/bin/sh
# Copyright (c) 2014 by galoisvsnaoya
# All rights reserved.
# 2014.12.20 1.00.00 To be fabricated

CreateDir() {
	if [ ! -d $1 ]; then
		mkdir -m 777 -p $1
	fi
	return 0
}

GetFile() {
	if [ -s $1 ]; then
		cp -fr $1 $2
	fi
	return 0
}

if [ "root" != `/usr/bin/whoami` ]; then
	echo "Usage : Please use this program as root user"
	exit 1
fi

DIR=`dirname $0`
PGM_ID=`basename $0`
timestamp1=`date +'%Y/%m/%d %H:%M:%S'`
timestamp2=`date +'%Y%m%d%H%M%S'`
mkdir -m 777 -p ${timestamp2}
cd ${timestamp2}
LOG_HOME=`pwd`

HOSTNAME=`uname -n`
IPADDRESS=`ifconfig|grep "inet addr"|grep -v "127.0.0.1"|awk '{print $2}'|awk -F":" '{print $2}'`
OS_TYPE=`uname`
OS_VERSION=`cat /etc/issue|head -1`
KERNEL=`uname -s`,`uname -r`,`uname -v`
HARDWARE_TYPE=`uname -m`
TIMEZONE=`cat /etc/sysconfig/clock|grep 'ZONE'|grep -v '#'|awk -F'=' '{print $2}'`
KEYTABLE=`cat /etc/sysconfig/keyboard|grep 'KEYTABLE'|awk -F'=' '{print $2}'`
LANG=`cat /etc/sysconfig/i18n|grep 'LANG'|awk -F'=' '{print $2}'`
LOCALE=`locale -a|grep "^C\|^POSIX\|ja*"`
RPM_PACKAGE=`rpm -qa|sort`
RUNLEVEL=`chkconfig --list`
server_config="
****************************************************************************************************
(A) SERVER config
****************************************************************************************************

(A01) hostname
----------------------------------------------------------------------------------------------------
${HOSTNAME}

(A02) IP address
----------------------------------------------------------------------------------------------------
${IPADDRESS}

(A03) OS type
----------------------------------------------------------------------------------------------------
${OS_TYPE}

(A04) OS version
----------------------------------------------------------------------------------------------------
${OS_VERSION}

(A05) kernel
----------------------------------------------------------------------------------------------------
${KERNEL}

(A06) hardware type
----------------------------------------------------------------------------------------------------
${HARDWARE_TYPE}

(A07) timezone
---------------------------------------------------------------------------------------------------
${TIMEZONE}

----------------------------------------------------------------------------------------------------
(A08) keytable
---------------------------------------------------------------------------------------------------
${KEYTABLE}

(A09) lang
----------------------------------------------------------------------------------------------------
${LANG}

(A10) locale
----------------------------------------------------------------------------------------------------
${LOCALE}

(A11) rpm package
----------------------------------------------------------------------------------------------------
${RPM_PACKAGE}

(A12) runlevel
----------------------------------------------------------------------------------------------------
${RUNLEVEL}

"

SYSTEM_HARDWARE_VENDOR=`lshal|grep "system.hardware.vendor"|awk -F"= " '{print $2}'|sed -e 's/  (string)//'`
SYSTEM_HARDWARE_PRODUCT=`lshal|grep "system.hardware.product"|awk -F"= " '{print $2}'|sed -e 's/  (string)//'`
MODEL=${SYSTEM_HARDWARE_VENDOR},${SYSTEM_HARDWARE_PRODUCT}
CHIPSET=`lspci|grep "00:00.0 Host bridge"|awk -F":" '{print $3}'|sed -e 's/^[ ]*//'`
GRAPHICBOARD=`lspci|grep "VGA"|awk -F":" '{print $3}'|sed -e 's/^[ ]*//'`
OPTICALDRIVE_TYPE=`lshal|grep "storage.cdrom"|grep "(bool)"|grep -v "support_media_changed"|grep true|awk -F"." '{print $3}'|awk -F"=" '{print $1}'`
if [ `echo ${#OPTICALDRIVE_TYPE}` -ne 0 ]; then
	OPTICALDRIVE_WRITESPEED=`lshal|grep "storage.cdrom.write_speed"|grep -v "write_speeds"|awk -F"=" '{print $2}'|awk -F"  " '{print $1}'`
	OPTICALDRIVE_WRITESPEED_DS=`expr ${OPTICALDRIVE_WRITESPEED} / 700`
	OPTICALDRIVE_READSPEED=`lshal|grep "storage.cdrom.read_speed"|awk -F"=" '{print $2}'|awk -F"  " '{print $1}'`
	OPTICALDRIVE_READSPEED_DS=`expr ${OPTICALDRIVE_READSPEED} / 700`
else
	OPTICALDRIVE_WRITESPEED=0
	OPTICALDRIVE_WRITESPEED_DS=0
	OPTICALDRIVE_READSPEED=0
	OPTICALDRIVE_READSPEED_DS=0
fi
BATTERY_TYPE=`lshal|grep "battery.type"|awk -F"=" '{print $2}'|sed -e 's/^[ ]*//'|sed -e 's/  (string)//'`
BATTERY_FULL_DESIGN=`lshal|grep "battery.reporting.design"|awk -F"=" '{print $2}'|awk -F"  " '{print $1}'`
if [ `echo ${#BATTERY_FULL_DESIGN}` -ne 0 ]; then
	BATTERY_FULL_DESIGN_W=`expr ${BATTERY_FULL_DESIGN} / 100`
else
	BATTERY_FULL_DESIGN_W=0
fi
PCI_BUS_DEVICE=`lspci`
SCSI_DEVICE=`cat /proc/scsi/scsi`
RAID_CONFIGURATION=`cat /proc/mdstat`
NETWORK=`lspci|grep "Ethernet controller"`
FIBRECHANNEL=`lspci|grep "Fibre Channel"`
USB_DEVICE=`lsusb`
hardware_config="
****************************************************************************************************
(B) HARDWARE config
****************************************************************************************************

(B01) model
----------------------------------------------------------------------------------------------------
${MODEL}

(B02) chipset
----------------------------------------------------------------------------------------------------
${CHIPSET}

(B03) graphicboard
----------------------------------------------------------------------------------------------------
${GRAPHICBOARD}

(B04) opticaldrive type
----------------------------------------------------------------------------------------------------
${OPTICALDRIVE_TYPE}

(B05) opticaldrive writespeed
----------------------------------------------------------------------------------------------------
${OPTICALDRIVE_WRITESPEED_DS} DS

(B06) opticaldrive readspeed
----------------------------------------------------------------------------------------------------
${OPTICALDRIVE_READSPEED_DS} DS

(B07) battery type
----------------------------------------------------------------------------------------------------
${BATTERY_TYPE}

(B08) battery full design
----------------------------------------------------------------------------------------------------
${BATTERY_FULL_DESIGN_W} W

(B09) PCI bus device
----------------------------------------------------------------------------------------------------
${PCI_BUS_DEVICE}

(B10) SCSI device
----------------------------------------------------------------------------------------------------
${SCSI_DEVICE}

(B11) RAID configuration
----------------------------------------------------------------------------------------------------
${RAID_CONFIGURATION}

(B12) network
----------------------------------------------------------------------------------------------------
${NETWORK}

(B13) fibrechannel
----------------------------------------------------------------------------------------------------
${FIBRECHANNEL}

(B14) USB device
----------------------------------------------------------------------------------------------------
${USB_DEVICE}

"

CPU_MODEL_NAME=`cat /proc/cpuinfo|grep "model name"|sort|uniq|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'`
VENDOR_ID=`cat /proc/cpuinfo|grep "vendor_id"|sort|uniq|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'`
FAMILY=`cat /proc/cpuinfo|grep "cpu family"|sort|uniq|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'`
CPU_MODEL=`cat /proc/cpuinfo|grep "model"|grep -v "model name"|sort|uniq|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'`
STEPPING=`cat /proc/cpuinfo|grep "stepping"|sort|uniq|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'`
SOCKET_QUANTITY=`cat /proc/cpuinfo|grep "physical id"|sort|uniq|wc -l`
PROCESSOR_QUANTITY=`cat /proc/cpuinfo|grep "processor"|sort|uniq|wc -l`
CORES=`cat /proc/cpuinfo|grep "cpu cores"|awk -F":" '{print $2}'|head -1|sed -e 's/^[ ]*//'`
MHz=`cat /proc/cpuinfo|grep "cpu MHz"|awk -F':' '{print $2}'|head -1|sed -e 's/^[ ]*//'`
CPU_CACHE_SIZE=`cat /proc/cpuinfo|grep 'cache size'|awk -F':' '{print $2}'|head -1|sed -e 's/^[ ]*//'`
cpu_config="
****************************************************************************************************
(C) CPU config
****************************************************************************************************

(C01) model name
----------------------------------------------------------------------------------------------------
${CPU_MODEL_NAME}

(C02) vendor id
----------------------------------------------------------------------------------------------------
${VENDOR_ID}

(C03) family
----------------------------------------------------------------------------------------------------
${FAMILY}

(C04) model
----------------------------------------------------------------------------------------------------
${CPU_MODEL}

(C05) stepping
----------------------------------------------------------------------------------------------------
${STEPPING}

(C06) socket quantity
----------------------------------------------------------------------------------------------------
x${SOCKET_QUANTITY}

(C07) processor quantity
----------------------------------------------------------------------------------------------------
x${PROCESSOR_QUANTITY}

(C08) cores
----------------------------------------------------------------------------------------------------
${CORES} CORE

(C09) MHz
----------------------------------------------------------------------------------------------------
${MHz}

(C10) cache size
----------------------------------------------------------------------------------------------------
${CPU_CACHE_SIZE}

"

PHYSICAL_TOTAL_KB=`cat /proc/meminfo|grep "MemTotal"|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'|awk '{print $1}'`
PHYSICAL_TOTAL_MB=`expr ${PHYSICAL_TOTAL_KB} / 1024`
PHYSICAL_FREE_KB=`cat /proc/meminfo|grep "MemFree"|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'|awk '{print $1}'`
PHYSICAL_FREE_MB=`expr ${PHYSICAL_FREE_KB} / 1024`
PHYSICAL_BUFFERS_KB=`cat /proc/meminfo|grep "Buffers"|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'|awk '{print $1}'`
PHYSICAL_CACHED_KB=`cat /proc/meminfo|grep "Cached"|grep -v "Swap"|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'|awk '{print $1}'`
PHYSICAL_BUFFERS_CACHED_KB=`expr ${PHYSICAL_BUFFERS_KB} + ${PHYSICAL_CACHED_KB}`
PHYSICAL_BUFFERS_CACHED_MB=`expr ${PHYSICAL_BUFFERS_CACHED_KB} / 1024`
PHYSICAL_ACTIVE_KB=`cat /proc/meminfo|grep "Active"|grep -v "("|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'|awk '{print $1}'`
PHYSICAL_INACTIVE_KB=`cat /proc/meminfo|grep "Inactive"|grep -v "("|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'|awk '{print $1}'`
PHYSICAL_ACTIVE_INACTIVE_KB=`expr ${PHYSICAL_ACTIVE_KB} + ${PHYSICAL_INACTIVE_KB}`
PHYSICAL_ACTIVE_INACTIVE_MB=`expr ${PHYSICAL_ACTIVE_INACTIVE_KB} / 1024`
PHYSICAL_ANONPAGES_KB=`cat /proc/meminfo|grep "AnonPages"|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'|awk '{print $1}'`
PHYSICAL_ANONPAGES_MB=`expr ${PHYSICAL_ANONPAGES_KB} / 1024`
PHYSICAL_TMPFS_KB=`expr ${PHYSICAL_ACTIVE_INACTIVE_KB} - ${PHYSICAL_BUFFERS_CACHED_KB} - ${PHYSICAL_ANONPAGES_KB}`
PHYSICAL_TMPFS_MB=`expr ${PHYSICAL_TMPFS_KB} / 1024`
PHYSICAL_USED_KERNEL_KB=`expr ${PHYSICAL_TOTAL_KB} - ${PHYSICAL_FREE_KB} - ${PHYSICAL_BUFFERS_CACHED_KB} - ${PHYSICAL_ANONPAGES_KB} - ${PHYSICAL_TMPFS_KB}`
PHYSICAL_USED_KERNEL_MB=`expr ${PHYSICAL_USED_KERNEL_KB} / 1024`
SWAP_TOTAL_KB=`cat /proc/meminfo|grep "SwapTotal"|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'|awk '{print $1}'`
SWAP_TOTAL_MB=`expr ${SWAP_TOTAL_KB} / 1024`
SWAP_FREE_KB=`cat /proc/meminfo|grep "SwapFree"|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'|awk '{print $1}'`
SWAP_FREE_MB=`expr ${SWAP_FREE_KB} / 1024`
SWAP_CACHED_KB=`cat /proc/meminfo|grep "SwapCached"|awk -F":" '{print $2}'|sed -e 's/^[ ]*//'|awk '{print $1}'`
SWAP_CACHED_MB=`expr ${SWAP_CACHED_KB} / 1024`
memory_config="
****************************************************************************************************
(D) MEMORY config
****************************************************************************************************

(D01) physical total
----------------------------------------------------------------------------------------------------
${PHYSICAL_TOTAL_MB} MB

(D02) physical free
----------------------------------------------------------------------------------------------------
${PHYSICAL_FREE_MB} MB (reference)

(D03) physical used kernel
----------------------------------------------------------------------------------------------------
${PHYSICAL_USED_KERNEL_MB} MB (reference)

(D04) physical buffers/cached
----------------------------------------------------------------------------------------------------
${PHYSICAL_BUFFERS_CACHED_MB} MB (reference)

(D05) physical anonpages
----------------------------------------------------------------------------------------------------
${PHYSICAL_ANONPAGES_MB} MB (reference)

(D06) physical tmpfs
----------------------------------------------------------------------------------------------------
${PHYSICAL_TMPFS_MB} MB (reference)

(D07) physical others
----------------------------------------------------------------------------------------------------
2 MB (reference)

(D08) swap total
----------------------------------------------------------------------------------------------------
${SWAP_TOTAL_MB} MB

(D09) swap free
----------------------------------------------------------------------------------------------------
${SWAP_FREE_MB} MB (reference)

(D10) swap cached
----------------------------------------------------------------------------------------------------
${SWAP_CACHED_MB} MB (reference)

"

FDISK=`fdisk -l|grep "/dev"`
PVDISPLAY=`pvdisplay|grep -v "Physical volume"`
VGDISPLAY=`vgdisplay|grep -v "Volume group"`
LVDISPLAY=`lvdisplay|grep -v "Logical volume"`
MOUNT=`mount|sort|grep -v "proc\|sysfs\|devpts\|tmpfs\|sunrpc"`
DF=`df -Ph|grep "^/dev"|sort|awk '{print $1,$6,$2}'`
DISK_BASE="DISK"
DISK_HOME="${LOG_HOME}/${DISK_BASE}"
CreateDir "${DISK_HOME}"
FSTAB_BASE="fstab"
FSTAB_HOME="${DISK_HOME}/${FSTAB_BASE}"
CreateDir "${FSTAB_HOME}"
GetFile "/etc/fstab" "${FSTAB_HOME}"
disk_config="
****************************************************************************************************
(E) DISK config
****************************************************************************************************

(E01) disk partition
----------------------------------------------------------------------------------------------------
${FDISK}

(E02) physical volume
----------------------------------------------------------------------------------------------------
${PVDISPLAY}

(E03) volume group
----------------------------------------------------------------------------------------------------
${VGDISPLAY}

(E04) logical group
----------------------------------------------------------------------------------------------------
${LVDISPLAY}

(E05) disk mount
----------------------------------------------------------------------------------------------------
${MOUNT}

(E06) disk total
----------------------------------------------------------------------------------------------------
${DF}

(E07) fstab
----------------------------------------------------------------------------------------------------
look at ${FSTAB_HOME} directory

"

NETWORK_BASE="NETWORK"
NETWORK_HOME="${LOG_HOME}/${NETWORK_BASE}"
CreateDir "${NETWORK_HOME}"
SYSCONFIG_NETWORK_BASE="sysconfig-network"
SYSCONFIG_NETWORK_HOME="${NETWORK_HOME}/${SYSCONFIG_NETWORK_BASE}"
CreateDir "${SYSCONFIG_NETWORK_HOME}"
GetFile "/etc/sysconfig/network" "${SYSCONFIG_NETWORK_HOME}"
IFCONFIG_BASE="ifconfig"
IFLOG_HOME="${NETWORK_HOME}/${IFCONFIG_BASE}"
CreateDir "${IFLOG_HOME}"
for i in 0 1 2 3 4 5 6 7 8 9
do
	GetFile "/etc/sysconfig/network-scripts/ifcfg-eth${i}" "${IFLOG_HOME}"
done
TEAMING_BASE="teaming"
TEAMING_HOME="${NETWORK_HOME}/${TEAMING_BASE}"
CreateDir "${TEAMING_HOME}"
for i in 0 1 2 3 4 5 6 7 8 9
do
	GetFile "/etc/sysconfig/network-scripts/ifcfg-bond${i}" "${TEAMING_HOME}"
done
VLAN_BASE="vlan"
VLAN_HOME="${NETWORK_HOME}/${VLAN_BASE}"
CreateDir "${VLAN_HOME}"
for i in 0 1 2 3 4 5 6 7 8 9
do
	GetFile "/etc/sysconfig/network-scripts/ifcfg-bond${i}.*" "${VLAN_HOME}"
done
ROUTING_BASE="routing"
ROUTING_HOME="${NETWORK_HOME}/${ROUTING_BASE}"
CreateDir "${ROUTING_HOME}"
GetFile "/etc/sysconfig/network-scripts/routing-*" "${ROUTING_HOME}"
HOSTS_BASE="hosts"
HOSTS_HOME="${NETWORK_HOME}/${HOSTS_BASE}"
CreateDir "${HOSTS_HOME}"
GetFile "/etc/hosts" "${HOSTS_HOME}"
NSSWITCH_BASE="nsswitch"
NSSWITCH_HOME="${NETWORK_HOME}/${NSSWITCH_BASE}"
CreateDir "${NSSWITCH_HOME}"
GetFile "/etc/nsswitch" "${NSSWITCH_HOME}"
NTP_BASE="ntp"
NTP_HOME="${NETWORK_HOME}/${NTP_BASE}"
CreateDir "${NTP_HOME}"
GetFile "/etc/ntp.conf" "${NTP_HOME}"
GetFile "/etc/sysconfig/ntpd" "${NTP_HOME}"
network_config="
****************************************************************************************************
(F) NETWORK config
****************************************************************************************************

(F01) sysconfig network
----------------------------------------------------------------------------------------------------
look at ${SYSCONFIG_NETWORK_HOME} directory

(F02) ifconfig
----------------------------------------------------------------------------------------------------
look at ${IFLOG_HOME} directory

(F03) teaming
----------------------------------------------------------------------------------------------------
look at ${TEAMING_HOME} directory

(F04) vlan
----------------------------------------------------------------------------------------------------
look at ${VLAN_HOME} directory

(F05) routing
----------------------------------------------------------------------------------------------------
look at ${ROUTING_HOME} directory

(F06) hosts
----------------------------------------------------------------------------------------------------
look at ${HOSTS_HOME} directory

(F07) nsswitch
----------------------------------------------------------------------------------------------------
look at ${NSSWITCH_HOME} directory

(F08) ntp
----------------------------------------------------------------------------------------------------
look at ${NTP_HOME} directory

"

OS_BASE="OS"
OS_HOME="${LOG_HOME}/${OS_BASE}"
CreateDir "${OS_HOME}"
SYSCTL_BASE="sysctl"
SYSCTL_HOME="${OS_HOME}/${SYSCTL_BASE}"
CreateDir "${SYSCTL_HOME}"
GetFile "/etc/sysctl.conf" "${SYSCTL_HOME}"
UDEV_BASE="udev"
UDEV_HOME="${OS_HOME}/${UDEV_BASE}"
CreateDir "${UDEV_HOME}"
GetFile "/etc/udev/rules.d" "${UDEV_HOME}"
KDUMP_BASE="kdump"
KDUMP_HOME="${OS_HOME}/${KDUMP_BASE}"
CreateDir "${KDUMP_HOME}"
GetFile "/boot/grub/grub.conf" "${KDUMP_HOME}"
GetFile "/etc/sysconfig/kdump" "${KDUMP_HOME}"
GetFile "/etc/kdump.conf" "${KDUMP_HOME}"
SNMP_BASE="snmp"
SNMP_HOME="${OS_HOME}/${SNMP_BASE}"
CreateDir "${SNMP_HOME}"
GetFile "/etc/sysconfig/snmpd" "${SNMP_HOME}"
GetFile "/etc/snmp/snmpd.conf" "${SNMP_HOME}"
SSH_BASE="ssh"
SSH_HOME="${OS_HOME}/${SSH_BASE}"
CreateDir "${SSH_HOME}"
GetFile "/etc/ssh/sshd_config" "${SSH_HOME}"
GetFile "/etc/ssh/ssh_config" "${SSH_HOME}"
SYSLOG_TYPE=`chkconfig --list|grep "syslog"|grep "on"|awk '{print $1}'`
SYSLOG_BASE="${SYSLOG_TYPE}"
SYSLOG_HOME="${OS_HOME}/${SYSLOG_BASE}"
CreateDir "${SYSLOG_HOME}"
if [ ${SYSLOG_TYPE} == "syslog" -o ${SYSLOG_TYPE} == "rsyslog" ]; then
	GetFile "/etc/sysconfig/syslog" "${SYSLOG_HOME}"
	GetFile "/etc/syslog.conf" "${SYSLOG_HOME}"
else
	GetFile "/opt/syslog-ng" "${SYSLOG_HOME}"
	GetFile "/opt/syslog-ng/etc/syslog-ng.conf" "${SYSLOG_HOME}"
fi
LOGROTATE_BASE="logrotate"
LOGROTATE_HOME="${OS_HOME}/${LOGROTATE_BASE}"
CreateDir "${LOGROTATE_HOME}"
GetFile "/usr/sbin/logrotate" "${LOGROTATE_HOME}"
GetFile "/etc/logrotate.conf" "${LOGROTATE_HOME}"
CRON_BASE="cron"
CRON_HOME="${OS_HOME}/${CRON_BASE}"
CreateDir "${CRON_HOME}"
GetFile "/etc/cron.hourly" "${CRON_HOME}"
GetFile "/etc/cron.daily" "${CRON_HOME}"
GetFile "/etc/cron.weekly" "${CRON_HOME}"
GetFile "/etc/cron.monthly" "${CRON_HOME}"
os_config="
****************************************************************************************************
(G) OS config
****************************************************************************************************

(G01) sysctl
----------------------------------------------------------------------------------------------------
look at ${SYSCTL_HOME} directory

(G02) udev
----------------------------------------------------------------------------------------------------
look at ${UDEV_HOME} directory

(G03) kdump
----------------------------------------------------------------------------------------------------
look at ${KDUMP_HOME} directory

(G04) snmp
----------------------------------------------------------------------------------------------------
look at ${SNMP_HOME} directory

(G05) ssh
----------------------------------------------------------------------------------------------------
look at ${SSH_HOME} directory

(G06) syslog
----------------------------------------------------------------------------------------------------
type:${SYSLOG_TYPE} ("syslog/rsyslog" or "syslog-ng"), look at ${SYSLOG_HOME} directory

(G07) logrotate
----------------------------------------------------------------------------------------------------
look at ${LOGROTATE_HOME} directory

(G08) cron
----------------------------------------------------------------------------------------------------
look at ${CRON_HOME} directory

"

USER_LIST=`cat /etc/passwd|grep "^root\|/home"|grep -v "nologin"`
GROUP_LIST_GREP_CONDITIONS=`cat /etc/passwd|grep "^root\|/home"|grep -v "nologin"|awk -F":" '{print ":"$4":"}'`
GROUP_LIST=`cat /etc/group|grep "${GROUP_LIST_GREP_CONDITIONS}"`
USER_BASE="USER"
USER_HOME="${LOG_HOME}/${USER_BASE}"
CreateDir "${USER_HOME}"
cat /etc/passwd|grep "^root\|/home"|grep -v "nologin" >> "${DIR}/${PGM_ID}_user.list"
while read LINE
do
	USER=`echo ${LINE}|awk -F":" '{print $1}'`
	PERUSER_BASE=${USER}
	PERUSER_HOME="${USER_HOME}/${PERUSER_BASE}"
	CreateDir "${PERUSER_HOME}"
	if [ ${USER} == "root" ]; then
		GetFile "/etc/bashrc" "${PERUSER_HOME}"
		GetFile "/etc/profile" "${PERUSER_HOME}"
		GetFile "/root/.vimrc" "${PERUSER_HOME}"
		crontab -l >> "${PERUSER_HOME}/cron.config"
	else
		USERPATH=`echo ${LINE}|awk -F":" '{print $6}'`
		CSHRC_FILEPATH="${USERPATH}/.cshrc"
		GetFile "${CSHRC_FILEPATH}" "${PERUSER_HOME}"
		KIBANCSH_FILEPATH="${USERPATH}/.kibancsh"
		GetFile "${KIBANCSH_FILEPATH}" "${PERUSER_HOME}"
		LOGIN_FILEPATH="${USERPATH}/.login"
		GetFile "${LOGIN_FILEPATH}" "${PERUSER_HOME}"
		crontab -l -u ${USER} >> "${PERUSER_HOME}/cron.config"
		GetFile "${USERPATH}/bin" "${PERUSER_HOME}"
		GetFile "${USERPATH}/bat" "${PERUSER_HOME}"
		GetFile "${USERPATH}/csh" "${PERUSER_HOME}"
	fi
done < "${DIR}/${PGM_ID}_user.list"
if [ -s ${DIR}/${PGM_ID}_user.list ]; then
	rm -f ${DIR}/${PGM_ID}_user.list
fi
user_config="
****************************************************************************************************
(H) USER config
****************************************************************************************************

(H01) user list
----------------------------------------------------------------------------------------------------
${USER_LIST}

(H02) group list
----------------------------------------------------------------------------------------------------
${GROUP_LIST}

(H03) peruser config
----------------------------------------------------------------------------------------------------
look at ${USER_HOME} directory

"

message="
${timestamp1}
${server_config}
${hardware_config}
${cpu_onfig}
${memory_config}
${disk_config}
${network_config}
${os_config}
${user_config}
"
echo "${message}" >> "${HOSTNAME}.specdoc"
chmod -R 777 ${LOG_HOME}

