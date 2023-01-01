all: build

CSI_SPEC := spec.md
CSI_PROTO := csi.proto
## Build go language bindings
CSI_A := csi.a
CSI_GO := lib/go/csi/csi.pb.go
CSI_PKG := lib/go/csi

# This is the target for building the temporary CSI protobuf file.
#
# The temporary file is not versioned, and thus will always be
# built on GitHub Actions.
$(CSI_PROTO).tmp: $(CSI_SPEC) Makefile
	echo "// Code generated by make; DO NOT EDIT." > "$@"
	cat $< | sed -n -e '/```protobuf$$/,/^```$$/ p' | sed '/^```/d' >> "$@"

# This is the target for building the CSI protobuf file.
#
# This target depends on its temp file, which is not versioned.
# Therefore when built on GitHub Actions the temp file will always
# be built and trigger this target. On GitHub Actions the temp file
# is compared with the real file, and if they differ the build
# will fail.
#
# Locally the temp file is simply copied over the real file.
$(CSI_PROTO): $(CSI_PROTO).tmp
ifeq (true,$(GITHUB_ACTIONS))
	diff "$@" "$?"
else
	diff "$@" "$?" > /dev/null 2>&1 || cp -f "$?" "$@"
endif

build: check

# If this is not running on GitHub Actions then for sake of convenience
# go ahead and update the language bindings as well.
ifneq (true,$(GITHUB_ACTIONS))
build: build_cpp build_go
endif


build_cpp:
	$(MAKE) -C lib/cxx

# The file exists, but could be out-of-date.
$(CSI_GO): $(CSI_PROTO)
	$(MAKE) -C lib/go csi/csi.pb.go

$(CSI_A): $(CSI_GO)
	go mod download
	go install ./$(CSI_PKG)
	go build -o "$@" ./$(CSI_PKG)

build_go: $(CSI_A)

clean:
	rm $(CSI_A)
	$(MAKE) -C lib/go $@

clobber: clean
	$(MAKE) -C lib/go $@
	rm -f $(CSI_PROTO) $(CSI_PROTO).tmp

# check generated files for violation of standards
check: $(CSI_PROTO)
	awk '{ if (length > 72) print NR, $$0 }' $? | diff - /dev/null

.PHONY: clean clobber check
