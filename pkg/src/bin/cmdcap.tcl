#!/usr/bin/env tclsh
# package require Tcl 8.5
package require Expect

proc die {msg} {
	puts "Error: $msg. Exiting"
	exit 1
}

proc main {} {
	# This is necessary for 'asciinema' to work
	set ::env(LC_ALL) "en_US.UTF-8"

	set flagCommand ""
	set flagInput ""
	set flagOutput ""

	for {set i 0} {$i < $::argc} {incr i} {
		set arg [lindex $::argv $i]

		switch -regexp $arg {
			-c|--command {
				incr i

				if {$i >= $::argc} {
					die "No value supplied for flag '--command'"
				}

				set flagCommand [lindex $::argv $i]

				if {[string match "-*" $flagCommand]} {
					die "No value supplied for flag '--command'"
				}
			}
			-i|--input {
				incr i

				if {$i >= $::argc} {
					die "No value supplied for flag '--input'"
				}

				set flagInput [lindex $::argv $i]

				if {[string match "-*" $flagInput]} {
					die "No value supplied for flag '--input'"
				}
			}
			-o|--output {
				incr i

				if {$i >= $::argc} {
					die "No value supplied for flag '--output'"
				}

				set flagOutput [lindex $::argv $i]

				if {[string match "-*" $flagOutput]} {
					die "No value supplied for flag '--output'"
				}
			}
			-h|--help {
				puts "cmdcap
Usage:
   cmdcap \[-c|--command\] <commandString> \[-i|--input\] <inputFile> \[-o|--output\] <outputFile>

Example:
   cmdcap -i commands.sh -o output.json
	cmdcap -c 'ls ~'
"
			}
		}
	}

	if {$flagInput == "" && $flagCommand == ""} {
		die "Failed to pass either input file or command string"
	}

	if {$flagInput != "" && $flagCommand != ""} {
		die "Must only pass either input file or command string"
	}

	if {$flagOutput == ""} {
		die "Failed to pass output file"
	}


	# set 'lines'
	if {$flagCommand == ""} {
		# Read file into memory
		set fd [open $flagInput]
		set lines [split [read $fd] "\n"]
		close $fd
		unset flagInput fd
	} else {
		set lines {}
		lappend lines $flagCommand
	}

	# Spawn process
	spawn asciinema rec --overwrite -i 2 -c "bash --noprofile --norc" $flagOutput
	expect "* you're done"
	sleep 0.3

	set send_human {.1 .3 1 .05 2}

	set shouldSendInput 0
	for {set i 0} {$i < [llength $lines]} {incr i} {
		set line [lindex $lines $i]

		# If the last line is empty, don't send it
		if {$i == [llength $lines] - 1 && $line == ""} {
			break
		}

		# Don't send Bash script first-line boilerplate or shellcheck things
		if {[regexp "^(# shellcheck|#!).*" $line match] } {
			continue
		}

		exp_send -h -- "$line\n"
		sleep 0.3
	}

	exp_send -- "\x04"
	expect eof
	sleep 4
	removeLastLine $flagOutput
	removeLastLine $flagOutput
}

proc removeLastLine {filename} {
	set f [open $filename]
	set theLines [split [read $f] "\n"]
	close $f

	set theLines [lreplace $theLines end end]

	set f [open $filename "w"]
	puts -nonewline $f [join $theLines "\n"]
	close $f
}

main
