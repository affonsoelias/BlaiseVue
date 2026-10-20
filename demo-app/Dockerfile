# =====================================================================
# BlaiseVue 4.0 + Synopse mORMot 2 Cloud-Native Micro-Container
# Multi-Stage Build Architecture (< 20 MB Final Runtime Image)
# =====================================================================

# ---------------------------------------------------------------------
# Stage 1: Build Native Linux Binary (Free Pascal Compiler)
# ---------------------------------------------------------------------
FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    fpc \
    binutils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy project source files
COPY server/ ./server/
COPY core/ ./core/ 2>/dev/null || true
COPY vendor/ ./vendor/ 2>/dev/null || true

# Compile native mORMot 2 server for Linux x86_64
WORKDIR /build/server
RUN fpc -Mobjfpc -Sh -O2 -XX -Xs \
    -Fu/build/vendor/mormot2/src/** \
    -FEbin \
    -oserver \
    server.lpr || \
    fpc -Mobjfpc -Sh -O2 -XX -Xs -FEbin -oserver server.lpr

# ---------------------------------------------------------------------
# Stage 2: Minimal Production Runtime (< 20 MB Alpine Image)
# ---------------------------------------------------------------------
FROM alpine:3.20 AS runtime

LABEL maintainer="BlaiseVue Core Team"
LABEL description="Ultra-lean BlaiseVue 4.0 + mORMot 2 Full-Stack Pascal Container"

RUN apk add --no-cache ca-certificates gcompat libc6-compat

# Security: Create unprivileged application user
RUN addgroup -g 1001 -S blaise && \
    adduser -u 1001 -S blaise -G blaise

WORKDIR /app

# Copy compiled native server executable from builder stage
COPY --from=builder /build/server/bin/server /app/server
RUN chmod +x /app/server

# Copy compiled frontend distribution (SPA)
COPY dist/ /app/dist/

# Set ownership to unprivileged user
RUN chown -R blaise:blaise /app

# Switch to non-root user
USER blaise

# Expose default HTTP/WebSocket port
EXPOSE 8090
ENV PORT=8090

# Healthcheck monitoring endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:8090/api/status || exit 1

# Launch native mORMot 2 server
ENTRYPOINT ["/app/server"]
CMD ["--port", "8090"]

