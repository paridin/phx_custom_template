# This should match the version of Alpine that the `elixir:1.7.2-alpine` image uses
FROM bitwalker/alpine-elixir-phoenix:latest AS builder

ARG COOKIE
# The environment to build with
ARG MIX_ENV=prod
# Set this to true if this release is not a Phoenix app
ARG SKIP_PHOENIX=false
# If you are using an umbrella project, you can change this
# argument to the directory the Phoenix app is in so that the assets
# can be built
ARG PHOENIX_SUBDIR=.
ARG HEX_ORG_NAME
ARG HEX_ORG_TOKEN
ARG SECRET_KEY_BASE

ENV SKIP_PHOENIX=${SKIP_PHOENIX} \
    MIX_ENV=${MIX_ENV} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    COOKIE=${COOKIE} \
    HEX_ORG_NAME=${HEX_ORG_NAME} \
    HEX_ORG_TOKEN=${HEX_ORG_TOKEN}

RUN mix local.hex --force && \
    mix local.rebar --force

ADD mix.exs mix.lock ./
COPY config config

RUN [[ ! -z "$HEX_ORG_NAME" && ! -z "$HEX_ORG_TOKEN" ]] && mix hex.organization auth ${HEX_ORG_NAME} --key ${HEX_ORG_TOKEN} || echo "no hex org configured"

RUN mix do deps.get --only ${MIX_ENV}, deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
COPY lib lib
# COPY rel rel

# This step builds assets for the Phoenix app (if there is one)
# If you aren't building a Phoenix app, pass `--build-arg SKIP_PHOENIX=true`
# This is mostly here for demonstration purposes
RUN if [ ! "$SKIP_PHOENIX" = "true" ]; then \
    cd ${PHOENIX_SUBDIR}/assets && \
    npm i && \
    npm run deploy && \
    cd - && \
    mix phx.digest; \
    fi

RUN mix do compile, release

RUN set -ex && \
    APP_NAME=$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g') && \
    APP_VSN=$(grep 'version:' mix.exs | cut -d '"' -f2) && \
    mkdir -p /opt/built && \
    tar -xvzf _build/${MIX_ENV}/${APP_NAME}-${APP_VSN}.tar.gz -C /opt/built

# From this line onwards, we're in a new image, which will be the image used in production
FROM alpine:3.11.6

RUN apk update && \
    apk add --no-cache \
    bash \
    curl \
    openssl-dev && \ 
    rm -rf /var/cache/apk/* 

EXPOSE 80

WORKDIR /opt/app

COPY --from=builder /opt/built /opt/app
COPY --from=builder /opt/app/priv/ssl /opt/ssl
CMD trap 'exit' INT; /opt/app/bin/$(ls /opt/app/bin) start