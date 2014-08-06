# get the directory where this script resides
set thisDir [file dirname [info script]]
# source common utilities
source $thisDir/utils.tcl

# script will be sourced from work directory
# output created in ip directory
set ipDir ./ip

create_project managed_ip_project $ipDir/managed_ip_project -part xc7z020clg484-1 -ip -force

create_ip -name axi_iic -vendor xilinx.com -library ip -module_name axi_iic_0 -dir $ipDir -force

# design revision: clock changed from 25 MHz to 100 MHz
set_property -dict [list CONFIG.AXI_ACLK_FREQ_MHZ {100}] [get_ips axi_iic_0]

generate_target all [get_files  */axi_iic_0.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] [get_files */axi_iic_0.xci]]
launch_run  axi_iic_0_synth_1
wait_on_run axi_iic_0_synth_1

# if everything is successful "touch" a file so make will note it's done
touch {.ip.done}