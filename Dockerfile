# stage1 - build react app first 

# set the base image
# This is the application image from which all other subsequent applications run
# Alpine Linux is a security-oriented, lightweight (~5Mb) Linux distribution. 
FROM node:alpine as build

# set working directory
# this is the working folder in the container from which the app will be running from
WORKDIR /app

# add the node_modules folder to $PATH
ENV PATH /app/node_modules/.bin:$PATH


COPY ./package.json /app/

# install  dependencies
RUN yarn --silent

# copy everything to /app directory
COPY . /app

RUN yarn build

# stage 2 - build the final image and copy the react build files
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/conf.d
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]