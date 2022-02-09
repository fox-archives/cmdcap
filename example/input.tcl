#!/usr/bin/env expect
spawn asciinema rec --overwrite -i 2 -c "bash --noprofile --norc" ./output.json

expect "* you're done"
sleep 0.5

send "ls ~\n"
sleep 0.5

send "\x04"

expect eof
