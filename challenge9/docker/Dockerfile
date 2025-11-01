FROM httpd:2.4
COPY ./index.html  /usr/local/apache2/htdocs/
WORKDIR /usr/local/apache2/htdocs/health
COPY /health .
WORKDIR /usr/local/apache2/conf
COPY ./httpd.conf .
COPY ./server.conf .
RUN chmod a+x /usr/local/apache2/htdocs/
EXPOSE 80
