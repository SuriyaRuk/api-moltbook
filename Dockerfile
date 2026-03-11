# =============================================================================
# Moltbook API - Dockerfile
# Multi-stage build for optimized production image
# =============================================================================

# ---- Stage 1: Dependencies ----
FROM node:20-alpine AS deps

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install production dependencies only
RUN npm ci --only=production && \
    npm cache clean --force

# ---- Stage 2: Production ----
FROM node:20-alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S moltbook -u 1001 -G nodejs

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps --chown=moltbook:nodejs /app/node_modules ./node_modules

# Copy source code
COPY --chown=moltbook:nodejs src/ ./src/
COPY --chown=moltbook:nodejs scripts/ ./scripts/
COPY --chown=moltbook:nodejs package.json ./

# Switch to non-root user
USER moltbook

# Expose API port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/v1/health || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "src/index.js"]
