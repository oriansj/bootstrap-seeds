# x86 Native Programs

The programs in this directory run as the initial boot program for an x86 machine.

They do not require a pre-existing POSIX kernel. Instead, they use the "native" interfaces provided by the machine.

The two most common native interfaces for an x86 machine are BIOS and UEFI. The following programs use the BIOS interface.


# stage0\_monitor

This program reads hexadecimal values from the keyboard, converts them to binary and writes them to memory starting at address 0x10000. It also allow executing the resulting code.

The stage0\_monitor.img file can be used as a drive image.

For example, it be run using the Qemu emulator with this command:

```
qemu-system-i386 -nographic -drive file=stage0_monitor.img,format=raw
```


# builder-hex0-x86-stage1

The builder-hex0-x86-stage1 tool is a tiny (200 byte) bootable program which contains a hex0 compiler which loads and compiles source from disk(starting at sector 2), places it into memory starting at address 0x7E00 and jumps to the resulting executable. Note that the stage1 code is only 200 bytes but it must be padded to 512 bytes with the Master Boot Record identifier bytes (0x55 0xAA) placed at the end to form a proper boot sector.

Like stage0\_monitor, builder-hex0-x86-stage1 is not particularly useful by itself but is enough to be combined with more source code to form a bootstrapping path to much more functionality.

For example, builder-hex0-x86-stage1 can be used to compile and run builder-hex0-x86-stage2. Builder-hex0-x86-stage2 is composed of a tiny POSIX kernel, shell, and file system that can be used to build software. Specifically, it has enough functionality to support the [stage0-posix-x86](https://github.com/oriansj/stage0-posix-x86) bootstrap and to run [live-bootstrap](https://github.com/fosslinux/live-bootstrap) up to the tcc compiler. Builder-hex0-x86-stage2 is not bootable by itself and cannot be used as a binary seed and so it is not hosted here.

All builder-hex0 programs are hosted [here](https://github.com/ironmeld/builder-hex0) where you can find further information and helper scripts for building the programs and running them under Qemu.  

The following is an example of building the POSIX x86 hex0-seed using helper scripts from the builder-hex0 repository. You could adapt them to build kaem-optional-seed as well.


## Building hex0-seed using builder-hex0-x86-stage1 and builder-hex0-x86-stage2

```
git clone https://github.com/ironmeld/builder-hex0
cd builder-hex0

make clean
make

cd BUILD

git clone https://github.com/oriansj/bootstrap-seeds
SEED_DIR=bootstrap-seeds/POSIX/x86

# create dev directory so we can write to /dev/hda
echo "src 0 /dev" > hex0.src

cp $SEED_DIR/hex0_x86.hex0 .

# Create commands to load hex0_x86.hex0 source, compile, and write result to /dev/hda
../hex0-to-src.sh ./hex0_x86.hex0 >> hex0.src

# Create disk image from seed and source, boot it, and extract result from resulting disk image
../build-stages.sh builder-hex0-x86-stage1.bin ../builder-hex0-x86-stage2.hex0 hex0.src hex0-seed

# Verify the pre-built hex0-seed is the same as the hex0-seed we built
diff $SEED_DIR/hex0-seed hex0-seed
```
