# --- Stage 1: Build ---
# 这个阶段用于安装所有依赖（包括开发依赖）并编译 TS -> JS
FROM node:20-alpine AS builder

WORKDIR /app

# 复制 package.json 文件并安装所有依赖
COPY package*.json ./
RUN npm ci

# 复制所有源代码
COPY . .

# 运行 build 脚本 (tsc)，它会读取 tsconfig.json 并生成 ./dist 目录
RUN npm run build


# --- Stage 2: Production ---
# 这个阶段用于创建一个干净、轻量的最终镜像
FROM node:20-alpine

WORKDIR /app

# 只复制生产环境需要的 package.json 文件
COPY package*.json ./
# 只安装生产依赖，这会让镜像更小、更安全
RUN npm ci --only=production

# 从 'builder' 阶段复制编译好的 JavaScript 代码
COPY --from=builder /app/dist ./dist

# 暴露 Cloud Run 将要使用的端口
EXPOSE 18080

# 最终的启动命令：用 node 直接运行编译后的 JS 文件
# 确保你的主文件是 server.js
CMD [ "node", "dist/server.js" ]
