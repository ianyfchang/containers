#!/bin/bash

# create web user
echo 'isJ.9rULcz1qI' > /local/tpp/users/victorng/.password 
echo 'isvrZZeXRoRDk' > /local/tpp/users/victorng_std1/.password 
echo 'isvrZZeXRoRDk' > /local/tpp/users/victorng_std2/.password 
chown -R www-data.www-data log users 
chmod -R 777 /local/data /local/tpp/users/*

# add users
useradd -d /home/victorng      -s /bin/tcsh -m victorng
useradd -d /home/victorng_std1 -s /bin/tcsh -m victorng_std1
useradd -d /home/victorng_std2 -s /bin/tcsh -m victorng_std2

chown -R victorng.victorng      /home/victorng
chown -R victorng.victorng_std1 /home/victorng_std1
chown -R victorng.victorng_std2 /home/victorng_std2

echo 'root:Nymu732!'|chpasswd
echo 'victorng:Nymu732!'|chpasswd
echo 'victorng_std1:ProtNymu732!'|chpasswd
echo 'victorng_std2:ProtNymu732!'|chpasswd

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
