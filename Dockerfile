FROM httpd:alpine

COPY index.html /usr/local/apache2/htdocs/

RUN sed -i 's/^Listen 80$/Listen 8080/' /usr/local/apache2/conf/httpd.conf && \
    chgrp -R 0 /usr/local/apache2/logs && \
    chmod -R g=u /usr/local/apache2/logs

EXPOSE 8080
