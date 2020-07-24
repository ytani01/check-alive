#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`

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

RET=0
for h in $HOSTS; do
    tseval ping -c 2 $h > /dev/null
    if [ $? -ne 0 ]; then
        tsecho "$h: down !?"
        RET=$?
    elif [ -n "$OPT_VERB" ]; then
        tsecho "$h: up"
    fi
done

exit $RET
