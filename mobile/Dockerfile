# Dockerfile for Flutter web
FROM node:18-alpine AS flutter-builder
RUN npm install -g dart sass

WORKDIR /app
COPY mobile .
RUN flutter pub get
RUN flutter build web

FROM node:18-alpine
WORKDIR /app
COPY --from=flutter-builder /app/build/web ./public
RUN npm install -g serve

EXPOSE 8080
CMD ["serve", "-s", "public", "-l", "8080"]
