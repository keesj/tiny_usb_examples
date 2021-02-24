#CROSS_COMPILE=riscv64-linux-gnu-
CROSS_COMPILE=riscv64-unknown-elf-

firmware.hex:

firmware.elf: sections.lds start.s firmware.c
	$(CROSS_COMPILE)gcc -march=rv32i -mabi=ilp32 -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -nostdlib -o firmware.elf start.s firmware.c

firmware.bin: firmware.elf
	$(CROSS_COMPILE)objcopy -O binary firmware.elf /dev/stdout > firmware.bin

firmware.hex: firmware.bin
	python3 makehex.py $^ 4096 > $@
