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

task.run() {
	# Basalt currently doesn't support Tcl, so we fake it
	BASALT_PACKAGE_DIR=$PWD tclsh "$PWD/pkg/bin/cmdcap.tcl" -c 'ls -al -- ~' -o ./example/output.json

	if (( $# == 0)); then
		./asciicast2gif/asciicast2gif ./example/output.json ./example/output.gif ./example/output.png
	else
		./asciicast2gif/asciicast2gif "$@"
	fi
}
