# syntax=docker/dockerfile:1

FROM rust:1.90.0 AS build

WORKDIR /usr/src/oxide-meta
COPY . .
RUN --mount=type=cache,target=/usr/src/oxide-meta/target \
	--mount=type=cache,target=/usr/local/cargo,from=rust:1.89.0,source=/usr/local/cargo \
	cargo build --release --package oxide_meta

FROM build AS artifacts

RUN --mount=type=cache,target=/usr/src/oxide-meta/target \
	mkdir /oxide-meta \
	&& cp /usr/src/oxide-meta/target/release/oxide_meta /oxide-meta/oxide_meta

FROM debian:trixie-slim

LABEL org.opencontainers.image.source=https://github.com/OxideLauncher/oxide-meta
LABEL org.opencontainers.image.title=oxide-meta
LABEL org.opencontainers.image.description="Oxide Launcher Minecraft metadata generator"
LABEL org.opencontainers.image.licenses=MIT

RUN apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates openssl \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=artifacts /oxide-meta /oxide-meta

WORKDIR /oxide-meta
CMD ["/oxide-meta/oxide_meta"]
