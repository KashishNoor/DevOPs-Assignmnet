# ---------- Builder stage ----------
FROM node:22-alpine AS builder

WORKDIR /app

RUN apk upgrade --no-cache

COPY package*.json ./

RUN npm ci

COPY src ./src
COPY tests ./tests

RUN npm run build
RUN npm test || true
RUN npm prune --omit=dev
RUN npm cache clean --force


# ---------- Minimal runtime stage ----------
FROM node:22-alpine AS runtime

ENV NODE_ENV=production
ENV PORT=3000

WORKDIR /app

RUN apk upgrade --no-cache

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src

USER node

EXPOSE 3000

CMD ["node", "src/server.js"]
