docker run \
-p 10401:10401 \
-p 10400:22 \
-v /home/tpp-docker-volume/user1/tpp-web-data/:/local/data/ \
-v /home/tpp-docker-volume/user1/:/home/user1/ \
-v /home/tpp-docker-volume/user1/tpp-web-data-user1/:/local/tpp/users/user1/ \
--restart=unless-stopped \
-d \
tpp-gui
