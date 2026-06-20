# Use Node.js version 20 on a lightweight Alpine Linux base. Alpine reduces the image size, attack surface, and deployment times.
FROM node:20-alpine

# Set the active working directory inside the container to /app. All future relative commands will execute in this context.
WORKDIR /app

# Copy package.json and package-lock.json first to take advantage of Docker's layer caching mechanism.
COPY package*.json ./

# Install only production dependencies. The --omit=dev flag prevents devDependencies from bloating the final container image.
RUN npm install --omit=dev

# Copy the rest of the application source code files into the container's working directory.
COPY . .

# Inform container runtimes that the app listens on port 8000. This is instructional and does not publish the port on the host automatically.
EXPOSE 8000

# Execute "npm start" as the main container process, starting the Express.js API server when the container boots.
CMD ["npm", "start"]

