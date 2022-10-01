FROM nginx:stable
RUN chown -R www-data:www-data *
COPY default.conf /etc/nginx/conf.d/default.conf