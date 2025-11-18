# Stage 1: Build the application
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the SvelteKit app
RUN npm run build

# Stage 2: Create the production image
FROM node:20-alpine

WORKDIR /app

# Copy the built app from the builder stage
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

# Expose the port the app will run on
EXPOSE 5173

# Set the command to start the Node.js server
# The SvelteKit node-adapter output is a standalone server
CMD ["node", "build/index.js"]
