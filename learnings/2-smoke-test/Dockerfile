FROM alpine:3.20 AS builder

RUN apk update && \
    apk add curl xz 

ARG ZIGVER

RUN mkdir -p /deps
WORKDIR /deps
RUN curl -LOs https://ziglang.org/download/$ZIGVER/zig-linux-$(uname -m)-$ZIGVER.tar.xz && \
    tar xf zig-linux-$(uname -m)-$ZIGVER.tar.xz 

WORKDIR /
COPY main.zig /main.zig
RUN deps/zig-linux-$(uname -m)-$ZIGVER/zig build-exe main.zig -Doptimize=ReleaseFast --name st

FROM scratch

COPY --from=builder /st /st
EXPOSE 1337
CMD ["/st"]
    
