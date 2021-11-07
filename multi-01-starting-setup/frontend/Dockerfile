FROM node

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 3000

# use the 'start' script
CMD [ "npm", "start" ]