##
## Make and program TinyFPGA BX
##

PROJTOP = top
TOP_SRC=src/${PROJTOP}.v src/fifo.v

RTL_DIR = ../ip
RTL_USB_DIR = ${RTL_DIR}/usb/src


SOURCES = \
    $(RTL_DIR)/generic/src/global_reset.v \
	$(RTL_USB_DIR)/edge_detect.v \
	$(RTL_USB_DIR)/usb_fs_in_arb.v \
	$(RTL_USB_DIR)/usb_fs_in_pe.v \
	$(RTL_USB_DIR)/usb_fs_out_arb.v \
	$(RTL_USB_DIR)/usb_fs_out_pe.v \
	$(RTL_USB_DIR)/usb_fs_pe.v \
	$(RTL_USB_DIR)/usb_fs_rx.v \
	$(RTL_USB_DIR)/usb_fs_tx_mux.v \
	$(RTL_USB_DIR)/usb_fs_tx.v \
	$(RTL_USB_DIR)/usb_reset_det.v \
	$(RTL_USB_DIR)/usb_serial_ctrl_ep.v \
	$(RTL_USB_DIR)/usb_uart_bridge_ep.v \
	$(RTL_USB_DIR)/usb_uart_core.v \
	$(RTL_USB_DIR)/usb_uart.v \
 	../gen/pll.v

SRC = $(TOP_SRC) $(SOURCES)

PIN_DEF = syn/pins.pcf

DEVICE = lp8k
PACKAGE = cm81

CLK_MHZ = 48

all: $(PROJTOP).rpt $(PROJTOP).bin

pll.v:
	icepll -i 16 -o $(CLK_MHZ) -m -f $@

lint: $(SRC)
	iverilog -grelative-include $^

synth: $(PROJTOP).json

$(PROJTOP).json: $(SRC)
	yosys -q -p 'synth_ice40 -top $(PROJTOP) -json $@' $^

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) --freq $(CLK_MHZ) --opt-timing --package $(PACKAGE) --pcf $(PIN_DEF) --json $*.json --asc $@

gui: $(PIN_DEF) $(PROJTOP).json
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PIN_DEF) --json $(PROJTOP).json --asc $(PROJTOP).asc --gui

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

prog: $(PROJTOP).bin
	tinyprog -p $<

clean:
	rm -f $(PROJTOP).json $(PROJTOP).asc $(PROJTOP).rpt $(PROJTOP).bin pll.v a.out

.SECONDARY:
.PHONY: all synth prog clean gui
