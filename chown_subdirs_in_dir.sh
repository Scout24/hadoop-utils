#!/bin/bash

USAGE="changes ownership of all subdirectories within a HDFS directory to a user with the same name
as the subdirectory, especially useful for directories /tmp/hadoop-yarn/staging/ and
/var/log/hadoop-yarn/apps\n
\n
usage: $0 <path to the HDFS parent directory whose subdirectories ownerships shall be changed>\n
\n
examples:\n
         $0 /var/log/hadoop-yarn/apps\n
         $0 /tmp/hadoop-yarn/staging\n"

function printUsageAndExit() {
  echo -e $USAGE
  exit 1
}

function chownSubdirectories() {
  DIR_TO_FIX=$1/
  
  for line in $(hdfs dfs -ls $DIR_TO_FIX | sed "s/  */\//g" | cut -d"/" -f3,13) ; do
    dir=$(echo $line | cut -d"/" -f2)
    user=$(echo $line | cut -d"/" -f1)
    if [[ $dir != $user ]] ; then
      echo "changing ownership of $DIR_TO_FIX$dir to $dir"
      sudo -u hdfs hdfs dfs -chown -R $dir $DIR_TO_FIX$dir
    else
      echo "$DIR_TO_FIX$dir belongs to $user - nothing to do"
    fi
  done
}

if [ $# -eq 1 ] ; then
  chownSubdirectories $1
else
  printUsageAndExit
fi

