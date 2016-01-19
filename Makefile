PHANTOM = node_modules/phantomjs/bin/phantomjs

FINAL=honeybadger.js

VERSION=v$(shell cat package.json | ruby -r json -e "puts JSON.parse(ARGF.read)['version'][/\d\.\d/]")
BUILD_DIR=build/$(VERSION)
CDN=//js.honeybadger.io/$(VERSION)
MINIFIED=honeybadger.min.js
SOURCE_MAP=honeybadger.min.js.map

BUILD_FILES = src/header.js \
							build/src/helpers.js \
							build/src/configuration.js \
							build/src/notice.js \
              build/src/honeybadger.js \
              build/src/instrumentation.js \
							src/footer.js

all: compile concat minify

clean:
	rm -rf build/

compile: clean
	coffee --compile --bare --output ./build .

concat: $(BUILD_FILES)
	cat $^ >$(FINAL)

minify:
	uglifyjs --source-map $(SOURCE_MAP) --source-map-url $(CDN)/$(SOURCE_MAP) -o $(MINIFIED) $(FINAL)
	mkdir -p $(BUILD_DIR)
	cp $(FINAL) $(BUILD_DIR)
	mv $(MINIFIED) $(BUILD_DIR)
	mv $(SOURCE_MAP) $(BUILD_DIR)

test: compile
	grunt jasmine
