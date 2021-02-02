FROM alpine:latest AS builder

RUN apk add git build-base gcc cmake
RUN git clone https://github.com/vhelin/wla-dx \
    && cd wla-dx \
    && mkdir build && cd build \
    && cmake .. \
    && cmake --build . --config Release

FROM alpine:latest

RUN apk add make

COPY --from=builder /wla-dx/build/binaries/wla-z80 /usr/local/bin/wla-z80
COPY --from=builder /wla-dx/build/binaries/wlalink /usr/local/bin/wlalink

WORKDIR /app

CMD ["make"]
