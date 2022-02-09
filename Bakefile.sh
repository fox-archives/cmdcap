# shellcheck shell=bash
# shellcheck disable=SC2164

task.init() {
	git submodule update --init --recursive

	cd ./asciicast2gif
	git apply ../patches/png.patch
	npm install
}

task.build() {
	cd ./asciicast2gif
	npm run build
}

task.prerun() {
	cd ./example
	LC_ALL=en_US.UTF-8 ./input.tcl
	tput cnorm
	sed -i '$ d' ./output.json # remove last 'exit' line
}

task.run() {
	if (( $# == 0)); then
		./asciicast2gif/asciicast2gif ./example/output.json ./example/output.gif ./example/output.png
	else
		./asciicast2gif/asciicast2gif "$@"
	fi
}
