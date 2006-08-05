#!/bin/sh

set -e

if [ -z "$languages" ]; then
    # Buildlist of languages to be included on the official website
    languages="en ca cs de el es fr ja ko pt pt_BR ru zh_CN zh_TW"
fi

if [ -z "$architectures" ]; then
    architectures="alpha arm hppa i386 ia64 m68k mips mipsel powerpc s390 sparc"
fi

if [ -z "$destination" ]; then
    destination="/tmp/manual"
fi

if [ -z "$formats" ]; then
    formats="html pdf txt"
fi

[ -e "$destination" ] || mkdir -p "$destination"

export official_build="1"
export web_build="1"
export manual_target="for_wdo"

for lang in $languages; do
    echo "Language: $lang";
    for arch in $architectures; do
        echo "Architecture: $arch"
        if [ -n "$noarchdir" ]; then
            destsuffix="$lang"
        else
            destsuffix="${arch}"
        fi
        ./buildone.sh "$arch" "$lang" "$formats"
        mkdir -p "$destination/$destsuffix"
        for format in $formats; do
            if [ "$format" = html ]; then
                mv ./build.out/html/* "$destination/$destsuffix"
            else
                # Do not fail because of missing PDF support for some languages
                mv ./build.out/install.$lang.$format "$destination/$destsuffix/install.$format.$lang" || true
            fi
        done

        ./clear.sh
    done
done

if [ "$manual_release" = "etch" ] ; then
    PRESEED="../en/appendix/example-preseed-etch.xml"
    LCKEEP="-v lckeep=1"
else
    PRESEED="../en/appendix/example-preseed-sarge.xml"
    LCKEEP=""
fi
if [ -f $PRESEED ] && [ -f preseed.awk ] ; then
    gawk -f preseed.awk $LCKEEP $PRESEED >$destination/example-preseed.txt
fi
