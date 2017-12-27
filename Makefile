DIST := dist
BIN := bin

EXECUTABLE := lgtm
IMPORT := github.com/go-gitea/lgtm

SHA := $(shell git rev-parse --short HEAD)

LDFLAGS += -X "github.com/go-gitea/lgtm/version.VersionDev=$(SHA)"

TARGETS ?= linux/*,darwin/*,windows/*
PACKAGES ?= $(shell go list ./... | grep -v /vendor/)

TAGS ?=

ifneq ($(DRONE_TAG),)
	VERSION ?= $(DRONE_TAG)
else
	ifneq ($(DRONE_BRANCH),)
		VERSION ?= $(DRONE_BRANCH)
	else
		VERSION ?= master
	endif
endif

.PHONY: all
all: build

.PHONY: clean
clean:
	go clean -i ./...
	rm -rf $(BIN) $(DIST)

.PHONY: generate
generate:
	@which go-bindata > /dev/null; if [ $$? -ne 0 ]; then \
		go get -u github.com/jteeuwen/go-bindata/...; \
	fi
	@which mockery > /dev/null; if [ $$? -ne 0 ]; then \
		go get -u github.com/vektra/mockery/...; \
	fi
	go generate $(PACKAGES)

.PHONY: fmt
fmt:
	go fmt $(PACKAGES)

.PHONY: vet
vet:
	go vet $(PACKAGES)

.PHONY: lint
lint:
	@which golint > /dev/null; if [ $$? -ne 0 ]; then \
		go get -u github.com/golang/lint/golint; \
	fi
	for PKG in $(PACKAGES); do golint -set_exit_status $$PKG || exit 1; done;

.PHONY: test
test:
	for PKG in $(PACKAGES); do go test -cover -coverprofile $$GOPATH/src/$$PKG/coverage.out $$PKG || exit 1; done;

.PHONY: check
check: test

.PHONY: test-mysql
test-mysql:
	DATABASE_DRIVER="mysql" DATABASE_DATASOURCE="root@tcp(mysql:3306)/test?parseTime=true" go test -v -cover $(IMPORT)/store/datastore

.PHONY: test-pgsql
test-pgsql:
	DATABASE_DRIVER="postgres" DATABASE_DATASOURCE="postgres://postgres@pgsql:5432/postgres?sslmode=disable" go test -v -cover $(IMPORT)/store/datastore

.PHONY: install
install: $(wildcard *.go)
	go install -v -tags '$(TAGS)' -ldflags '-s -w $(LDFLAGS)'

.PHONY: build
build: $(BIN)/$(EXECUTABLE)

$(BIN)/$(EXECUTABLE): $(wildcard *.go)
	go build -v -tags '$(TAGS)' -ldflags '-s -w $(LDFLAGS)' -o $@

.PHONY: release
release: release-build release-copy release-check

.PHONY: release-build
release-build:
	@which xgo > /dev/null; if [ $$? -ne 0 ]; then \
		go get -u github.com/karalabe/xgo; \
	fi
	xgo -dest $(BIN) -tags '$(TAGS)' -ldflags '-s -w $(LDFLAGS)' -targets '$(TARGETS)' -out $(EXECUTABLE)-$(VERSION) $(IMPORT)

.PHONY: release-copy
release-copy:
	mkdir -p $(DIST)/release
	$(foreach file,$(wildcard $(BIN)/$(EXECUTABLE)-*),cp $(file) $(DIST)/release/$(notdir $(file));)

.PHONY: release-check
release-check:
	cd $(DIST)/release; $(foreach file,$(wildcard $(DIST)/release/$(EXECUTABLE)-*),sha256sum $(notdir $(file)) > $(notdir $(file)).sha256;)

.PHONY: latest
latest: release-build latest-copy latest-check

.PHONY: latest-copy
latest-copy:
	mkdir -p $(DIST)/latest
	$(foreach file,$(wildcard $(BIN)/$(EXECUTABLE)-*),cp $(file) $(DIST)/latest/$(subst $(EXECUTABLE)-$(VERSION),$(EXECUTABLE)-latest,$(notdir $(file)));)

.PHONY: latest-check
latest-check:
	cd $(DIST)/latest; $(foreach file,$(wildcard $(DIST)/latest/$(EXECUTABLE)-*),sha256sum $(notdir $(file)) > $(notdir $(file)).sha256;)

.PHONY: publish
publish: release latest
