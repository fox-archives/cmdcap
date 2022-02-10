#!/usr/bin/env expect

proc main {} {
	set scriptFile "./input.sh"
	set outputFile "./output.json"

	# Read file into memory
	set fd [open $scriptFile]
	set lines [split [read $fd] "\n"]
	close $fd
	unset scriptFile fd

	# Spawn process
	spawn asciinema rec --overwrite -i 2 -c "bash --noprofile --norc" $outputFile
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
	removeLastLine $outputFile
	removeLastLine $outputFile
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
