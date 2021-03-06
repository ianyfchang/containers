#!/bin/bash

# create an web user
mkdir /local/tpp/users/user1

echo `perl gen_tpp_web_passwd.pl YOURPASSWORD` > /local/tpp/users/user1/.password 
chown -R www-data.www-data log users 

# add users
useradd -d /home/user1 -s /bin/tcsh -m user1

chown -R user1.user1      /home/user1

echo 'user1:YOURPASSWORD'|chpasswd

# Start the first process
/usr/sbin/sshd -D &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start SSHD: $status"
  exit $status
fi

# Start the second process
/usr/sbin/apache2ctl -DFOREGROUND &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start APACHE2: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container will exit with an error
# if it detects that either of the processes has exited.
# Otherwise it will loop forever, waking up every 60 seconds
  
while /bin/true; do
  ps aux |grep sshd |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep apache2 |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they will exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit -1
  fi
  sleep 60
done
