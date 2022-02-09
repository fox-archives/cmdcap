# shellcheck shell=bash

task.init() {
	git submodule update --init --recursive
	cd asciicast2gif
	npm install
}

task.build() {
	cd asciicast2gif
	npm run build
}

task.prerun() {
	cd .hidden
	LC_ALL=en_US.UTF-8 ./input.sh
	sed -i '$ d' ./.hidden/output.json # remove last 'exit' line
}

task.run() {
	cd asciicast2gif
	if (( $# == 0)); then
		DEBUG=1 ./asciicast2gif ../.hidden/output.json ../.hidden/output.gif ../.hidden/output.png
	else
		./asciicast2gif "$@"
	fi
}
