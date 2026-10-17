# Thin wrapper around build.sh (see README: Articles pipeline).
.PHONY: articles strict sitemap verify

articles:
	./build.sh

strict:
	./build.sh --strict

sitemap:
	./build.sh --update-sitemap

# Build twice and prove the output is byte-identical.
verify:
	./build.sh >/dev/null
	find articles -type f | LC_ALL=C sort | xargs sha256sum > /tmp/xsar-articles.1
	./build.sh >/dev/null
	find articles -type f | LC_ALL=C sort | xargs sha256sum > /tmp/xsar-articles.2
	cmp /tmp/xsar-articles.1 /tmp/xsar-articles.2 && echo "byte-identical: $$(wc -l < /tmp/xsar-articles.1) files"
