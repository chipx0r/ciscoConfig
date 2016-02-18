#!/usr/local/bin/bash
#
# The purpose of this script is to automate configuration changes to a
# large number of devices. The script identifies the device list, as well
# as the change script, and then pushes the changes one by one.
#

CLOGINPATH="/usr/home/rancid/bin/clogin"
CREDENTIALS="/usr/home/rancid/.cloginrc"
DEVICELISTPATH="/usr/home/rancid/device-lists/"
CHANGESCRIPTPATH="/usr/home/rancid/change-scripts/"
CHANGELOG="/usr/home/rancid/logs/changelog-`date +%m-%d-%Y`.log"

clear
echo "=====[ Rancid Config Push Script ]====="
echo ""
echo "Please enter the proposed device list:"
echo "`ls $DEVICELISTPATH`"
echo "--------------------------------------"
echo -n "> "
read DEVICELIST

if [ -f $DEVICELISTPATH$DEVICELIST ]
then
echo ""
echo "Device List = \"./device-lists/$DEVICELIST\" (confirmed)"
else
echo ""
echo "Device list = \"./device-lists/$DEVICELIST\" (does not exist!)"
echo "Aborting..."
echo ""
exit
fi

echo ""
echo "Please enter name of change script:"
echo "`ls $CHANGESCRIPTPATH | grep -v ".sh" | grep -v "device-lists"`"
echo "-----------------------------------"
echo -n "> "
read CHANGESCRIPT

if [ -f $CHANGESCRIPTPATH$CHANGESCRIPT ]
then
echo ""
echo "Change Script = \"./change-scripts/$CHANGESCRIPT\" (confirmed)"
echo ""
else
echo "Device list = \"./change-scripts/$CHANGESCRIPT\" (does not exist!)"
echo "Aborting..."
echo ""
exit
fi

echo "-- Proposed Changes --"
echo "`cat $CHANGESCRIPTPATH$CHANGESCRIPT`"
echo "-- Proposed Changes --"
echo ""
echo "Are you sure you want to proceed? If so, type \"yes\":"
echo -n "> "
read AREYOUSURE

if [ $AREYOUSURE != "yes" ]
then
echo ""
echo "Aborting..."
echo ""
exit
else
echo ""
echo "Implementing Changes..."
echo ""
fi

#for i in `cat $DEVICELISTPATH$DEVICELIST`
# do echo "===[ $i ]==="
# $CLOGINPATH -f $CREDENTIALS -x $CHANGESCRIPTPATH$CHANGESCRIPT $i
#done

for DEVICE in `cat $DEVICELISTPATH$DEVICELIST`
do
echo "===[ $DEVICE ]==="
echo "" >> $CHANGELOG
echo "===[ $DEVICE ]===" >> $CHANGELOG
echo "" >> $CHANGELOG
OUTPUT=`$CLOGINPATH -f $CREDENTIALS -x $CHANGESCRIPTPATH$CHANGESCRIPT $DEVICE`
echo "$OUTPUT" >> $CHANGELOG
done
