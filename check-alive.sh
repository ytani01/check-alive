#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`

MAIL_TO=root@ytani.net

MAIL_SUBJECT="${MYNAME}@`hostname`"
MAIL_CMD=/usr/bin/mail
MAIL_FILE=/tmp/${MYNAME}.txt

OPT_VERB=

###
usage() {
    echo
    echo "    usage: $MYNAME [-h] [-v] host1 [host2 ..]"
    echo
}

tsecho() {
    #_TSECHO_DATASTR=`LANG=C date +'%Y/%m/%d %T'`
    _TSECHO_DATASTR=`LANG=C date +'%F %T'`
    echo $_TSECHO_DATASTR ${MYNAME}: $*
}

tseval() {
    _TSEVAL_CMDLINE=$*
    if [ -n "$OPT_VERB" ]; then
        tsecho "$_TSEVAL_CMDLINE"
    fi
    eval "$_TSEVAL_CMDLINE"
    _TSEVAL_RET=$?
    if [ $_TSEVAL_RET -ne 0 ]; then
        tsecho "ERROR($_TSEVAL_RET)"
    fi
    return $_TSEVAL_RET
}

### init

while getopts vh OPT; do
    case $OPT in
        v) OPT_VERB=true;;
        h) usage; exit 0;;
        *) usage; exit 1;;
    esac
done
shift `expr $OPTIND - 1`

HOSTS=$*
if [ -z "$HOSTS" ]; then
    usage
    exit 1
fi

### main

if [ -n "$OPT_VERB" ]; then
   tsecho "=== start ==="
fi
tsecho "=== start ===" > $MAIL_FILE 2>&1

RET=0
for h in $HOSTS; do
    tseval ping -c 2 $h > /dev/null
    _RET=$?
    if [ $_RET -ne 0 ]; then
        RET=$_RET
        tsecho "x $h: down !?"
        tsecho "x $h: down !?" >> $MAIL_FILE 2>&1
    elif [ -n "$OPT_VERB" ]; then
        tsecho "o $h: up"
        tsecho "o $h: up" >> $MAIL_FILE 2>&1
    fi
done

if [ -n "$OPT_VERB" ]; then
    tsecho "===  end  ==="
fi
tsecho "===  end  ===" >> $MAIL_FILE 2>&1

if [ $RET -ne 0 ]; then
    tseval "$MAIL_CMD -s "$MAIL_SUBJECT" $MAIL_TO < $MAIL_FILE"
fi

exit $RET
