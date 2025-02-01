FROM node:22.13.1-alpine3.20 AS base

# Remote Caching
ARG TURBO_TEAM
ENV TURBO_TEAM=$TURBO_TEAM
# End Remote Caching

FROM base AS build
RUN apk update
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

WORKDIR /usr/src/app

# Replace <your-major-version> with the major version installed in your repository. For example:
# RUN yarn global add turbo@^2
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
RUN pnpm install turbo --global
COPY . .

# Use secrets for TURBO_TOKEN during turbo prune
RUN --mount=type=secret,id=TURBO_TOKEN,env=TURBO_TOKEN

# Generate a partial monorepo with a pruned lockfile for a target workspace.
# Assuming "docs" is the name entered in the project's package.json: { name: "docs" }
RUN turbo prune docs --docker

# Add lockfile and package.json's of isolated subworkspace
FROM base AS installer
RUN apk update
RUN apk add --no-cache libc6-compat
WORKDIR /usr/src/app

# First install the dependencies (as they change less often)
COPY --from=build /usr/src/app/out/json/ .
RUN corepack enable
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

# Build the project
COPY --from=build /usr/src/app/out/full/ .
RUN pnpm turbo run build

FROM base AS runner
WORKDIR /usr/src/app

# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=installer --chown=nextjs:nodejs /usr/src/app/apps/docs/.next/standalone ./
COPY --from=installer --chown=nextjs:nodejs /usr/src/app/apps/docs/.next/static ./apps/docs/.next/static
COPY --from=installer --chown=nextjs:nodejs /usr/src/app/apps/docs/public ./apps/docs/public

ENV NODE_ENV=production \
    PORT=3000

EXPOSE 3000

CMD ["node", "apps/docs/server.js"]