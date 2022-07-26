FROM nginx:stable

RUN rm /etc/nginx/conf.d/default.conf

ADD ./env/docker/nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./env/docker/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /app
ADD ./src/public /app/public

CMD ["nginx"]

EXPOSE 80
