FROM amd64/nginx AS build-stage
 
RUN echo 'hello world this version is 4.0' > /usr/share/nginx/html/index.html