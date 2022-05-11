FROM node:18-bullseye AS git

RUN apt update && apt install -y git

FROM git AS frontend-builder

WORKDIR /build

RUN git clone https://github.com/ringtools/ringtools-web-v2 .

RUN cp .env.defaults .env && yarn install

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

RUN yarn build

FROM git AS api-builder

WORKDIR /build
RUN git clone https://github.com/ringtools/ringtools-server-ts .
RUN yarn install && yarn build:ts
RUN npm prune --production

FROM node:18-bullseye-slim 

USER 1000

WORKDIR /build
COPY --from=api-builder /build .
COPY --from=frontend-builder /build/dist/ringtools-web public

EXPOSE 7464
CMD ["node", "dist/server.js"]
