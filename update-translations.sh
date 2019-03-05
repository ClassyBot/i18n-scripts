#!/bin/bash

# exit on error
set -e

# show commands being executed
set -x

cd "$(dirname "$0")"

# cp-i18n-rsync: pull translations over from the GlotPress server

rsync \
	-rltv --delete \
	cp-i18n-rsync:/tmp/cp-translations/ \
	./cp-translations/

pushd cp-translations/build/
	for project in [a-z]*; do
		echo "project: $project"
		pushd $project/export/
			for locale in [a-z]*; do
				echo "locale: $locale"
				pushd $locale
					msgfmt "$locale.po" -o "$locale.mo"
					zip -9 -j "$locale.zip" \
						"$locale.po" "$locale.mo"
					cp -va "$locale.zip" ../../1.0.0/
				popd
			done
		popd
		mkdir -p ../api/$project/
		cp -var $project/1.0.0/ ../api/$project/
	done
popd

# classicpress_api-v1_*: push translations over to the API server

rsync -rltv --delete \
	cp-translations/api/ \
	cp-update-translations-api-v1-test:/www/src/ClassicPress-APIs_api-v1-test/v1/translations/

rsync -rltv --delete \
	cp-translations/api/ \
	cp-update-translations-api-v1:/www/src/ClassicPress-APIs_api-v1/v1/translations/
