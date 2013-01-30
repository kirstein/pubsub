R = spec
MOCHA = ./node_modules/.bin/mocha
COVERAGE_FILE = coverage.html
G = ""
TESTS = $(shell find test -name "*.test.js")

test: test-unit

test-unit: test-env
	echo "Running unit tests..."
	$(MOCHA) $(TESTS) -c -R $(R) -g $(G)

build: test
	echo "Building PubSub..."
	cake build

coverage: src-cov test-env
	echo "Running coverage using all tests..."
	@COVERAGE=1 $(MOCHA) $(TESTS) -c -R html-cov --compilers coffee:coffee-script test/*.test.coffee > $(COVERAGE_FILE)
	echo 'Coverage complete. Check "$(COVERAGE_FILE)" for results'

test-env:
	@NODE_ENV=test

src-cov:
	rm -rf src-cov
	@coffeeCoverage ./src ./src-cov
	@coffeeCoverage --exclude node_modules,.git,test ./src src-cov

.PHONY: test coverage src-cov test-unit build
.SILENT: test coverage src-cov test-unit build