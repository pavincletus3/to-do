# ---- Builder Stage ----
# This stage builds our application and installs all dependencies
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files and install all dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy the rest of the application source code
COPY . .


# ---- Production Stage ----
# This is the final, lean image that will be deployed
FROM node:18-alpine

WORKDIR /app

# Copy only the necessary files from the 'builder' stage
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/app.js ./app.js
COPY --from=builder /app/node_modules ./node_modules

# Expose the port the app runs on
EXPOSE 8080

# The command to run the application
CMD ["npm", "start"]