DIST := dist
BIN := bin

EXECUTABLE := lgtm
IMPORT := github.com/go-gitea/lgtm

SHA := $(shell git rev-parse --short HEAD)
SOURCES ?= $(shell find . -name "*.go" -type f)

LDFLAGS += -X "github.com/go-gitea/lgtm/version.VersionDev=$(SHA)"

TARGETS ?= linux darwin windows
ARCHS ?= amd64 386
PACKAGES ?= $(shell go list -mod=vendor ./... | grep -v /vendor/)

ifneq ($(shell uname), Darwin)
	EXTLDFLAGS = -extldflags "-static" $(null)
else
	EXTLDFLAGS =
endif

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
lint: golangci-lint

.PHONY: golangci-lint
golangci-lint:
	@hash golangci-lint > /dev/null 2>&1; if [ $$? -ne 0 ]; then \
		export BINARY="golangci-lint"; \
		curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(GOPATH)/bin v1.31.0; \
	fi
	golangci-lint run --timeout 5m

.PHONY: test
test:
	go test -mod=vendor -cover -coverprofile coverage.out $(PACKAGES) || exit 1

.PHONY: check
check: test

.PHONY: test-mysql
test-mysql:
	DATABASE_DRIVER="mysql" DATABASE_DATASOURCE="root@tcp(mysql:3306)/test?parseTime=true" go test -v -cover $(IMPORT)/store/datastore

.PHONY: test-pgsql
test-pgsql:
	DATABASE_DRIVER="postgres" DATABASE_DATASOURCE="postgres://postgres@pgsql:5432/postgres?sslmode=disable" go test -v -cover $(IMPORT)/store/datastore

.PHONY: install
install: $(SOURCES)
	go install -v -tags '$(TAGS)' -ldflags '-s -w $(LDFLAGS)'

.PHONY: build
build: $(BIN)/$(EXECUTABLE)

$(BIN)/$(EXECUTABLE): $(SOURCES)
	go build -mod=vendor -v -tags '$(TAGS)' -ldflags '-s -w $(LDFLAGS)' -o $@

release: release-dirs release-build release-copy release-check

release-dirs:
	mkdir -p $(DIST)/binaries $(DIST)/release

release-build:
	@hash gox > /dev/null 2>&1; if [ $$? -ne 0 ]; then \
		$(GO) get -u github.com/mitchellh/gox; \
	fi
	gox -os="$(TARGETS)" -arch="$(ARCHS)" -tags="$(TAGS)" -ldflags="$(EXTLDFLAGS)-s -w $(LDFLAGS)" -output="$(DIST)/binaries/$(EXECUTABLE)-$(subst v,,$(VERSION))-{{.OS}}-{{.Arch}}"

release-copy:
	$(foreach file,$(wildcard $(DIST)/binaries/$(EXECUTABLE)-*),cp $(file) $(DIST)/release/$(notdir $(file));)

release-check:
	cd $(DIST)/release; $(foreach file,$(wildcard $(DIST)/release/$(EXECUTABLE)-*),sha256sum $(notdir $(file)) > $(notdir $(file)).sha256;)
