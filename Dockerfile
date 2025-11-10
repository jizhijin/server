# backend/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
# Cloud Run 会注入 PORT 环境变量，通常是 8080。
EXPOSE 8000
ENTRYPOINT [ "npm","install" ]
CMD [ "ts-node-dev", "src/server.ts" ]
