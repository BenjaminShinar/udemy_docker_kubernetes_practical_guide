FROM node

#copy everything from the folder into the image at app folder. 
COPY . /app

# move to working directory
WORKDIR /app

# expose port
EXPOSE 80

# run commands when the image is created
RUN npm install

# run this when the container starts
CMD [ "node", "server.js" ]