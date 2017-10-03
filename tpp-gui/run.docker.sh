docker run \
--cpus 0.5 \
--memory 64g \
-p 10401:10401 \
-p 10400:22 \
-v /home/tpp-docker-volume/victorng/tpp-web-data/:/local/data/ \
-v /home/tpp-docker-volume/victorng/:/home/victorng/ \
-v /home/tpp-docker-volume/victorng_std1/:/home/victorng_std1/ \
-v /home/tpp-docker-volume/victorng_std2/:/home/victorng_std2/ \
-v /home/tpp-docker-volume/victorng/tpp-web-data-victorng/:/local/tpp/users/victorng/ \
-v /home/tpp-docker-volume/victorng_std1/tpp-web-data-victorng_std1/:/local/tpp/users/victorng_std1/ \
-v /home/tpp-docker-volume/victorng_std2/tpp-web-data-victorng_std2/:/local/tpp/users/victorng_std2/ \
--restart=unless-stopped \
-d \
tpp-gui
