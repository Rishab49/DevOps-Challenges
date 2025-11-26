FROM httpd:2.4
RUN echo "<h1> It is working on $(hostname)" > /usr/local/apache2/htdocs/index.html
WORKDIR /usr/local/apache2/htdocs/health
COPY /health .
WORKDIR /usr/local/apache2/conf
COPY ./httpd.conf .
COPY ./server.conf .
RUN chmod a+x /usr/local/apache2/htdocs/
EXPOSE 80
