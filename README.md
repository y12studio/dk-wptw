## This is a Developer-Test-Only Image

Docker Wordpress zh_TW 

base on [elsonrodriguez/docker-wordpress](https://github.com/elsonrodriguez/docker-wordpress) and [y12studio/docker-wordpress-zhtw](https://github.com/y12studio/docker-wordpress-zhtw) 

## how to run the wordpress zh_TW version

```
$ sudo docker run -d -p 80:80 y12docker/dk-wptw
```

## how to enable SSL

```
$ sudo docker run y12docker/dk-wptw /cli.sh cmdssl y12docker/dk-wptw | sudo bash
$ sudo docker run -d -p 80:80 -p 443:443 y12docker/dk-wptw:ssl
$ sudo docker run y12docker/dk-wptw /cli.sh psip
$ sudo docker run y12docker/dk-wptw /cli.sh psip | sudo bash
```

