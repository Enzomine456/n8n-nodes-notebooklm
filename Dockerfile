# Use Node.js 18 LTS as base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Build the TypeScript code
RUN npm run build

# Remove dev dependencies to reduce image size
RUN npm prune --production

# Create a non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S n8n -u 1001

# Change ownership of the app directory
RUN chown -R n8n:nodejs /app
USER n8n

# Expose port (if needed for development)
EXPOSE 3000

# Default command
CMD ["node", "dist/index.js"]
