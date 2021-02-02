# sms-toolchain

Docker container to run a Sega Master System build toolchain using [WLA-DX](https://github.com/vhelin/wla-dx)

## Usage

### Install

Pull the latest image from Docker Hub:

```sh
docker pull alexw88/sms-toolchain
```

To build the container locally:

```sh
git clone https://github.com/aw88/sms-toolchain.git
cd sms-toolchain
docker build -t alexw88/sms-toolchain .
```

### Run

To run a `wla-dx` build using a `Makefile`:

```sh
docker run --rm -v $(pwd):/app alexw88/sms-toolchain
```

The following tools are available within the container:

Tool      | Usage
----------|-----------
`make`    | [GNU make](https://www.gnu.org/software/make/manual/make.html)
`wla-z80` | Z80 assembler
`wlalink` | WLA-DX Linker
