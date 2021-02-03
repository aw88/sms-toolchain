FROM debian:stable-slim AS wla-builder

# Install dependencies
RUN apt update && apt install -y git gcc cmake \
  && rm -rf /var/lib/apt/lists/*

# Pull WLA-DX code and build
RUN git clone https://github.com/vhelin/wla-dx \
    && cd wla-dx \
    && mkdir build && cd build \
    && cmake .. \
    && cmake --build . --config Release

FROM debian:stable-slim AS sdcc-builder

# Install dependencies
RUN apt update && apt install -y wget bzip2 git gcc \
  && rm -rf /var/lib/apt/lists/*

# Pull SDCC snapshot
RUN wget -O sdcc-snapshot-amd64-unknown-linux2.5-20210131-12036.tar.bz2 https://sourceforge.net/projects/sdcc/files/snapshot_builds/amd64-unknown-linux2.5/sdcc-snapshot-amd64-unknown-linux2.5-20210131-12036.tar.bz2/download \
  && tar jxvf sdcc-snapshot-amd64-unknown-linux2.5-20210131-12036.tar.bz2 \
  && rm sdcc-snapshot-amd64-unknown-linux2.5-20210131-12036.tar.bz2

# Pull devkitSMS
RUN git clone --depth=1 https://github.com/sverx/devkitSMS
RUN chmod +x /devkitSMS/assets2banks/src/assets2banks.py

# Build folder2c
WORKDIR /devkitSMS/folder2c/src/
RUN gcc folder2c.c -o folder2c

# Build ihx2sms
WORKDIR /devkitSMS/ihx2sms/src/
RUN gcc ihx2sms.c -o ihx2sms

# Build makesms
WORKDIR /devkitSMS/makesms/src/
RUN gcc makesms.c -o makesms


FROM debian:stable-slim

RUN apt update && apt install -y make python \
  && rm -rf /var/lib/apt/lists/*

# Copy WLA-DX binaries
COPY --from=wla-builder /wla-dx/build/binaries/wla-z80 /usr/local/bin/wla-z80
COPY --from=wla-builder /wla-dx/build/binaries/wlalink /usr/local/bin/wlalink

# Copy SDCC
COPY --from=sdcc-builder /sdcc/bin/ /usr/local/bin/
COPY --from=sdcc-builder /sdcc/share/sdcc/include/ /share/sdcc/include
COPY --from=sdcc-builder /sdcc/share/sdcc/lib/z80/ /share/sdcc/lib/z80

# Copy devkitSMS helpers
COPY --from=sdcc-builder /devkitSMS/folder2c/src/folder2c /usr/local/bin/
COPY --from=sdcc-builder /devkitSMS/assets2banks/src/assets2banks.py /usr/local/bin/assets2banks
COPY --from=sdcc-builder /devkitSMS/ihx2sms/src/ihx2sms /usr/local/bin/
COPY --from=sdcc-builder /devkitSMS/makesms/src/makesms /usr/local/bin/

ENV SDCC_LIB /share/sdcc/lib
ENV SDCC_INCLUDE /share/sdcc/include/

WORKDIR /app

CMD ["make"]
