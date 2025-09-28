FROM node:20-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

# Add environment variables with defaults
ENV DB_USER=user \
    DB_PASSWORD=password \
    DB_NAME=laptop_store \
    DB_HOST=laptop_db \
    INSTANCE_ID=APP_1

EXPOSE 3000

CMD [ "node", "server.js" ]