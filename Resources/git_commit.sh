#!/bin/sh

#  git_commit.sh
#  DailyNote
#
#  Created by WeiHan on 9/23/15.
#  Copyright (c) 2015 Will Han. All rights reserved.


COMMIT_MSG=$1
COMMIT_DATE=$2

GITPATH=`which git`

echo "git->$GITPATH\n"

STATUS_LOG=`$GITPATH status`

echo "$STATUS_LOG\n"

if [[ $STATUS_LOG == *"nothing to commit"* ]]
then
    exit EXIT_SUCCESS
fi

STAGE_LOG=`$GITPATH add -A --force --verbose .`

echo "$STAGE_LOG\n"


COMMIT_LOG=`$GITPATH commit -a -m "$COMMIT_MSG" --date "$COMMIT_DATE"`

echo "$COMMIT_LOG\n"
