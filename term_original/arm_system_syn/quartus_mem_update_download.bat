quartus_cdb --update_mif ARM_System.qpf
quartus_asm ARM_System.qpf
quartus_pgm -c usb-blaster -m jtag -o p;ARM_System.sof
