# syntax=docker/dockerfile:1.10.0

FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS prune
RUN apk update
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /usr/src/app
RUN pnpm add -g turbo
COPY . .
RUN turbo prune docs --docker

# Add lockfile and package.json's of isolated subworkspace
FROM base AS build
RUN apk update
RUN apk add --no-cache libc6-compat
WORKDIR /usr/src/app

# First install the dependencies (as they change less often)
COPY --from=prune /usr/src/app/out/json/ .
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

# Build the project
COPY --from=prune /usr/src/app/out/full/ .

ARG NEXT_PUBLIC_API_URL
ARG TURBO_TEAM

RUN --mount=type=secret,id=turbo_token,env=TURBO_TOKEN \
    pnpm turbo build

FROM base AS run
WORKDIR /usr/src/app

# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=build --chown=nextjs:nodejs /usr/src/app/apps/docs/.next/standalone ./
COPY --from=build --chown=nextjs:nodejs /usr/src/app/apps/docs/.next/static ./apps/docs/.next/static
COPY --from=build --chown=nextjs:nodejs /usr/src/app/apps/docs/public ./apps/docs/public

CMD ["node", "apps/docs/server.js"]