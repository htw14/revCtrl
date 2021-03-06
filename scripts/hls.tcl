# get the directory where this script resides
set thisDir [file dirname [info script]]
# source common utilities
source $thisDir/utils.tcl

open_project rgb_mux
set_top rgb_mux
add_files ../hls/rgb_mux.cpp
open_solution "solution_zc702"
set_part {xc7z020clg484-1}
create_clock -period 5.0 -name default
set_clock_uncertainty 1.0
source "../hls/directives.tcl"
#csim_design
csynth_design
#cosim_design -trace_level none -rtl verilog -tool auto
export_design -format ip_catalog -description "rgb_mux" -version "2.3" -display_name "rgb_mux"

if {![file exists ./cip]} {
   # make the directory if it does not exist
   file mkdir ./cip
}
if {![file exists ./cip/rgb_mux]} {
   # make the directory if it does not exist
   file mkdir ./cip/rgb_mux
}

# now copy the packaged ip from the solution directory
set ipPkg ./rgb_mux/solution_zc702/impl/ip/xilinx_com_hls_rgb_mux_2_3.zip
if {[file exists $ipPkg]} {
   # TODO - for some reason bd gen tcl does not work if the zip file is not extracted
   #file copy -force $ipPkg ./cip/rgb_mux
   ## extract the packaged contents to the custom ip dir so it can be used in IPI
   # TODO - not sure why this is not working - investigate $PATH from inside HLS
   #exec "unzip -o $ipPkg -d ./cip/rgb_mux/"
   #exec "C:/Xilinx/Vivado_HLS/2014.4/msys/bin/unzip -o $ipPkg -d ./cip/rgb_mux/"
   # copy the contents of the extracted zip file instead
   foreach f {bd constraints doc hdl misc xgui component.xml} {
      file copy -force ./rgb_mux/solution_zc702/impl/ip/$f ./cip/rgb_mux
   }
} else {
   # something bad happened - packaged ip files missing
   # exit with an error
   puts "ERROR:  packaged ip file missing $ipPkg"
   exit
}

# if everything is successful "touch" a file so make will not it's done
touch {.hls.done}

exit
