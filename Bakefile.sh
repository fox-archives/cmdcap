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
	if (( $# == 0)); then
		BASALT_PACKAGE_DIR=$PWD tclsh "$PWD/pkg/bin/cmdcap.tcl" -c 'ls -a -- ~; sleep 3' -o ./example/output.json
	else
		BASALT_PACKAGE_DIR=$PWD tclsh "$PWD/pkg/bin/cmdcap.tcl" "$@"
	fi
}
