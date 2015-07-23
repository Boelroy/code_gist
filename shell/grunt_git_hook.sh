#!/bin/sh

# LOCAL_GIT_DIR=/home/bowen/www/
# LOCAL_GIT_DIR=/Users/Boelroy/Desktop/test/

while getopts "g:v:l:u:d:" arg
do
  case $arg in
    g)
      GIT_URL=$OPTARG
      ;;
    v)
      GIT_VERSION=$OPTARG
      ;;
    l)
      GIT_LOCAL_PATH=$OPTARG
    ;;
    u)
      GIT_USER_NAME=$OPTARG
      ;;
    d)
      GIT_DIST_PATH=$OPTARG
      ;;
    ?)
      echo "unkonw argument"
      exit 1;
    ;;
  esac
done

if [ ! -d $GIT_LOCAL_PATH ]; then
  echo >&2 "warning: post-receive: DEPLOY_DIR_NOT_EXIST:\"$GIT_LOCAL_PATH\""
  #if not exist the local path then try to create the path
  mkdir $GIT_LOCAL_PATH
  if [ $? -ne 0 ]
  then
    echo >&2 "could not mkdir $GIT_LOCAL_PATH"
    exit 1;
  fi

fi
cd $GIT_LOCAL_PATH

#check wheather the dir is the git dir
IS_BARE=$(git rev-parse --is-bare-repository)
if [ -z "$IS_BARE" ];then
  #check the the clone address is empty
  if [ -n "$GIT_URL" ]
  then
    git clone $GIT_URL .
  else
    echo >&2 "fatal: empty git address"
    exit 0;
  fi

fi

#pull the latest version
env -i git pull

#checkout to the target version
if [ -n "$GIT_VERSION" ]
then
  git checkout $GIT_VERSION
fi

which bower >& /dev/null
if [ $? -eq 0 ]
then
  bower install
  echo >&2"bower is not installed"
else
  exit 1;
fi
which npm >& /dev/null
if [ $? -eq 0 ]
then
  npm install
  echo >&2"bower is not installed"
else
  exit 1;
fi
which grunt >& /dev/null
if [ $? -eq 0 ]
then
  grunt build --force
  echo >&2"bower is not installed"
else
  exit 1;
fi

LOCAL_DIST_DIR=./dist/
if [ -n "$GIT_DIST_PATH" ]
then
    echo >&2 "fatal: post-receive: DEPLOY_DIR_EMPTY:\"$GIT_DIST_PATH\""
fi
if [ ! -d $GIT_DIST_PATH ]; then
  echo >&2 "fatal: post-receive: DEPLOY_DIR_NOT_EXIST:\"$GIT_DIST_PATH\""
  exit 1
fi
# rm -rf $GIT_DIST_PATH/*
mv -f $LOCAL_DIST_DIR/* $GIT_DIST_PATH
