FROM nginx:alpine
# COPY nginx.conf /etc/nginx/nginx.conf
COPY dist/reddit-youtube /usr/share/nginx/html
