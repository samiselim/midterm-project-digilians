# STAGE 1: Build Stage. Initialize a Node.js build environment on lightweight Alpine Linux, aliasing this step as "build".
FROM node:20-alpine AS build

# Set the active working directory inside the build container to /app.
WORKDIR /app

# Copy package configurations first to take advantage of cached Docker layers for dependencies.
COPY package*.json ./

# Install all packages (including development packages like Vite and React compile toolchains).
RUN npm install

# Copy all application files (source, layouts, configs) to the build workspace.
COPY . .

# Run the build script. Vite compiles JSX and asset dependencies, outputting optimized static assets into "/app/dist".
RUN npm run build

# STAGE 2: Runtime Stage. Start a fresh stage with a lightweight Nginx Alpine image, discarding the heavy Node.js build container.
FROM nginx:alpine

# Copy the compiled static assets from the "/app/dist" folder of the "build" stage into Nginx's default public directory.
COPY --from=build /app/dist /usr/share/nginx/html

# Replace the default Nginx site configuration with our custom config file to handle client-side routing and proxying.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Document that the web server container will listen on port 80 (standard HTTP port).
EXPOSE 80

# Start Nginx in the foreground ("daemon off;") to keep the container running as a persistent web server process.
CMD ["nginx", "-g", "daemon off;"]

