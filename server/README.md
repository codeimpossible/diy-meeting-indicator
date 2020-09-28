## Installing the status light service

Install dependencies

```
$ pypi install -r requirements.txt
```

Create a background service using systemctl

```
$ cd ./diy-meeting-indicator/server
$ systemctl enable statuslight.service
```

Configure NGINX

```
$ cp ./diy-meeting-indicator/server/statuslight.nginx.conf /etc/nginx/sites-enabled/statuslight.nginx.conf
```

Start the service, if it isn't already

```
systemctl start statuslight.service
```
