# Start with a Node.js base image
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first to leverage layer caching
COPY package*.json ./

# ---- Dependencies Stage ----
# This stage installs ALL dependencies, including dev dependencies if you had them.
FROM base AS dependencies
# Install dependencies
RUN npm install

# ---- Production Stage ----
# This is the final, lean image.
FROM node:alpine AS production
# Install ONLY production dependencies.
RUN npm ci --omit=dev
# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 8080

# The command to run the application
CMD ["npm", "start"]