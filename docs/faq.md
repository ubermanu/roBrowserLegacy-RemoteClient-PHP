# FAQ

## How I can change NGINX/Apache virtual host configuration?

The vhosts configuration for both Apache and NGINX are baked into the container recipe. If you need to change this, 
you have to modify the respective [Apache Dockerfile](../docker/apache/Dockerfile) or [NGINX dockerfile](../docker/nginx/Dockerfile)
and re-run the docker compose command.

You can also override vhost configuration on **/etc/apache2/sites-available/000-default.conf** for Apache or **/etc/nginx/conf.d/default.conf** for NGINX
using docker compose specification adding a bind mount, example:

```yaml
volumes:
  - ./:/var/www/html:ro
  - ./my-own-nginx.conf:/etc/nginx/conf.d/default.conf
```

## How can I make sure that my remote client works as expected?

If you set up all the required files correctly, you can run the python script [tester.py](../docker/test/tester.py). This
script reads a file list in the same directory (list.txt) that contains multiple filenames that should be in a GRF.
The script will request each file to the target webserver defined in **TARGET_SERVER_ADDRESS** variable, checking if the 
server answers with an HTTP code 200, if not, a new log file is created with the HTTP code and the file url requested, so
you can debug it afterward.

Example, running the list against a working server (localhost, apache and nginx):

### Apache

```
=== Final result ===
Total: 2784 | OK: 2784 | FAIL: 0
Elapsed time: 110.10 seconds
```

### NGINX

```
=== Final result ===
Total: 2784 | OK: 2784 | FAIL: 0
Elapsed time: 1.86 seconds
```

## How this remote client works?

![](how-it-works-high.png)
