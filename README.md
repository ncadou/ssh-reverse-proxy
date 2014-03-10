Nginx reverse proxy docker environment
======================================

Uses Hans Donner's nginx docker container as a base:
https://raw.github.com/hans-d/docker-nginx/

Allows serving up HTTP content (e.g. from your dev box) to the internet at
large despite being otherwise unaccessible behind a firewalled home router,
without having to open any ports on said router. The trick consists of using
SSH's remote forwards on a publicly accessible server.

Uses the default nginx configuration, and will include everything in
`/data/nginx`.

SSH HTTP tunnel
---------------

In addition to running nginx, the container will connect to the SSH server of
your choice to tunnel HTTP traffic back to itself. Parameters are configurable
through environment variables given to `docker run`.

Those variables are:
- `HTTP_TUNNEL_HOST` (hostname of the SSH server to connect to)
- `HTTP_TUNNEL_PORT` (SSH server port)
- `HTTP_TUNNEL_USER` (SSH username)
- `HTTP_TUNNEL_IDENTITY` (name of the SSH private key in `/data/ssh`)

As an example, you could use a WebFaction account to pipe all HTTP traffic to
your development computer at home.

To accomplish this you would add a website in your WebFaction control panel
using the domain name of your choice, with a single `Custom app (listening on
port)` application mounted on `/`. WebFaction will assign a port to your app
which you will reuse like so (assuming you neatly place all your docker
volumes in some location like `/srv/docker/volumes`):

```
export VOLUMES=/srv/docker/volumes/ssh-reverse-proxy
sudo mkdir -p $VOLUMES/data/ssh
sudo ssh-keygen -f $VOLUMES/data/ssh/tunnel-key
docker run -d --name ssh-reverse-proxy \
           -v $VOLUMES/data:/data \
           -v $VOLUMES/log:/var/log \
           -e HTTP_TUNNEL_HOST=<webfaction-username>.webfactional.com \
           -e HTTP_TUNNEL_PORT=<webfaction-app-port> \
           -e HTTP_TUNNEL_USER=<webfaction-username> \
           -e HTTP_TUNNEL_IDENTITY=tunnel-key ncadou/ssh-reverse-proxy
```

You would also need to add `tunnel-key.pub` to your WebFaction shell account's
`~/.ssh/authorized_keys` file. Because the private key you just created can't
have a passphrase (so that the container can use it unattended) it's probably a
good idea to make it useless for anything but port forwarding, by prepending
something like this to it:

`command="/bin/true",no-X11-forwarding,no-agent-forwarding,no-pty`

Once the container has been created with `docker run`, it can be controlled
with `docker (stop|start|restart) ssh-reverse-proxy`. If left running at system
shutdown, the docker daemon will automatically restart it at the next boot.

What nginx is going to serve, and under which domain(s), is left an exercise to
you, the user. Just add whatever is needed in `/data/nginx` and have at it.

Note: if you want to access the nginx server locally, just add `-p 80:80` to
the `docker run` command above, and fire up a browser to http://localhost.

Volumes
-------

- `/data`: website
  - `/data/nginx`: additional configuration for nginx
  - `/data/ssh`: SSH keys for the HTTP tunnel
- `/var/log`: logging
  - `/var/log/nginx`: output of nginx (as per default configuration) 
