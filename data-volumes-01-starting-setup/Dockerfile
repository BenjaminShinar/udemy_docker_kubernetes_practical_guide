FROM node

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 80

#use an anonymous volume to keep the node_modules
VOLUME ["/app/node_modules"]

# use the 'start' script
CMD [ "npm", "start" ]