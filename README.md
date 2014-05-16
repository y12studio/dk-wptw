## This is a Developer-Test-Only Image

Docker Wordpress zh_TW 

base on [elsonrodriguez/docker-wordpress](https://github.com/elsonrodriguez/docker-wordpress) and [y12studio/docker-wordpress-zhtw](https://github.com/y12studio/docker-wordpress-zhtw) 

## how to run the wordpress zh_TW version

```
$ sudo docker run -d -p 80:80 y12docker/dk-wptw
```

## how to enable SSL

```
$ sudo docker pull y12docker/dk-wptw
$ sudo docker run y12docker/dk-wptw /cli.sh cmdssl y12docker/dk-wptw | sudo bash
$ sudo docker run -d -p 80:80 -p 443:443 y12docker/dk-wptw:ssl
$ sudo docker run y12docker/dk-wptw /cli.sh psip
$ sudo docker run y12docker/dk-wptw /cli.sh psip | sudo bash
```

## How to enable data-container

run with persistent data volume container

```
$ sudo docker run y12docker/dk-wptw /cli.sh run
Syntax Error, ex: cli.sh run <name> <port> <img>

$ sudo docker run y12docker/dk-wptw /cli.sh run foo2 80 y12docker/dk-wptw
echo "create new data container for dk-wptw"
docker run --name foo2-data -v /var/lib/mysql -v /var/www busybox /bin/true
echo "run dk-wptw with data container"
docker run -d -p 80:80 --name foo2 --volumes-from foo2-data y12docker/dk-wptw

$ sudo docker run y12docker/dk-wptw /cli.sh run foo2 80 y12docker/dk-wptw | sudo bash
```
