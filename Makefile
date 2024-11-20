.PHONY: serve build publish clean display

serve:
	zola serve --open

build:
	zola build

publish:
	gh workflow run build.yml

display:
	gh run list --workflow=build.yml

clean:
	rm -rf public
