#!/bin/bash

# exit on error
set -e

# show commands being executed
set -x

cd "$(dirname "$0")"

# cp-i18n-rsync: pull translations over from the GlotPress server

rsync \
	-e 'ssh cp-i18n-rsync' \
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
					msgfmt "$project-$locale.po" -o "$project-$locale.mo"
					zip -9 -j "$locale.zip" \
						"$project-$locale.po" "$project-$locale.mo"
					cp -va "$locale.zip" ../../1.0.0/
				popd
			done
		popd
		mkdir -p ../api/$project/
		cp -var $project/1.0.0/ ../api/$project/
	done
popd

rsync -rltv --delete \
	cp-translations/api/ \
	~/api-v1.classicpress.net/v1/translations/
