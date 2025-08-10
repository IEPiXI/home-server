FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app

RUN apk add --no-cache bash

RUN npm install -g ring-client-api@11.7.1

COPY package.json package-lock.json ./
RUN npm install --omit=dev
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/get_ring_token.sh .

RUN sed -i 's/\r$//' get_ring_token.sh

RUN chmod +x get_ring_token.sh

CMD ["node", "dist/server.js"]
