# Use an official Node.js runtime as the base image
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --ignore-scripts

# Copy the rest of the app's source code
COPY src ./src
COPY index.html ./index.html
COPY tsconfig.app.json ./tsconfig.app.json
COPY tsconfig.json ./tsconfig.json
COPY tsconfig.node.json ./tsconfig.node.json
COPY vite.config.ts ./vite.config.ts

# Build the React app
RUN npm run build

# Use a lightweight web server for static files
FROM node:18-alpine AS serve

# Create a non-root user and group for the serve stage
RUN npm install -g serve \
    && addgroup --system nodeapp \
    && adduser --system --ingroup nodeapp nodeapp

# Set working directory
WORKDIR /app

# Copy build artifacts from previous stage
COPY --from=build --chown=root:root --chmod=755 /app/dist .

# Switch to the non-root user for running the application
USER nodeapp

# Expose the port the app runs on
EXPOSE 3000

# Command to run the app
CMD ["serve", "-s", ".", "-l", "3000", "--no-clipboard"]
