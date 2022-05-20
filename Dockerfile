FROM nginx
COPY nginx/nginx.conf /etc/nginx/conf.d/
COPY html /usr/share/nginx/html
EXPOSE 8080
EXPOSE 8443
