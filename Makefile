.PHONY: serve build publish clean

serve:
	zola serve

build:
	zola build

publish:
	gh workflow run build.yml

clean:
	rm -rf public
