# Poll the FIFO output side and print samples as they arrive

# 1) Find & open the first JTAG master
set masters [get_service_paths master]
if {[llength $masters] == 0} {
    puts "ERROR: no JTAG master!"
    exit
}
set mpath [lindex $masters 0]
open_service master $mpath
puts "Using JTAG master: $mpath"

# 2) Base addresses for your FIFO
set DATA_BASE 0xFF010000    ;# data port (half‑word samples)
set CSR_BASE  0xFF020000    ;# CSR base (32‑bit regs)

# 3) Offsets (in words) into the CSR space
set OFF_FILL      0   ;# fill_level (we won't use this here)
set OFF_ISTATUS   1   ;# instantaneous status
set OFF_EVENT     2   ;# sticky events (RW1C)
set OFF_IE        3   ;# interrupt‑enable
set OFF_AFULL     4   ;# almost‑full threshold
set OFF_AEMPTY    5   ;# almost‑empty threshold

# 4) Polling loop with reset recovery
set running 1
while {$running} {
    # Use catch to handle potential JTAG errors
    if { [catch {
        # a) Read the instantaneous status
        set stat_list [master_read_32 $mpath [expr {$CSR_BASE + $OFF_ISTATUS*4}] 1]
        set status    [lindex $stat_list 0]
        
        # b) Test EMPTY bit (bit 1). If EMPTY==0, data is available.
        if { ($status & 0x2) == 0 } {
            # Read one 16‑bit sample from the FIFO data port
            set data_list [master_read_32 $mpath $DATA_BASE 1]
            set sample    [lindex $data_list 0]
            puts [format "FIFO out: %d" $sample]
        }
    } error_msg] } {
        # Handle JTAG error - try to reconnect
        puts "JTAG error detected: $error_msg"
        puts "Attempting to reconnect..."
        
        # Close the current connection
        catch {close_service master $mpath}
        
        # Wait for FPGA to stabilize after reset
        after 2000
        
        # Try to reopen the connection
        catch {
            set masters [get_service_paths master]
            if {[llength $masters] > 0} {
                set mpath [lindex $masters 0]
                open_service master $mpath
                puts "Reconnected to JTAG master: $mpath"
            } else {
                puts "No JTAG masters found. Will retry..."
            }
        }
        
        # Wait before retrying
        after 1000
    }
    
    # c) Back off a bit to avoid over‑polling
    after 10   ;# 10 ms
}

# To stop: Ctrl+C in System Console, then optionally:
#   close_service master $mpath