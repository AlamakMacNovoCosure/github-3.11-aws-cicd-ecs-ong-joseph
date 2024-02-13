FROM node:14

WORKDIR /joseph-express-app/

COPY package*.json ./

RUN npm install

COPY . .

CMD [ "npm", "start" ]
