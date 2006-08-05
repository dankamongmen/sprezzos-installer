#!/bin/sh

set -e

if [ -z "$languages" ]; then
    # Please add languages only if they build properly.
    # languages="en cs es fr ja nl pt_BR" # ca da de el eu it ru

    # Buildlist of languages to be included on RC3 CD's
    languages="en cs de es fr ja pt_BR ru"
fi

if [ -z "$architectures" ]; then
    architectures="alpha arm hppa i386 ia64 m68k mips mipsel powerpc s390 sparc"
fi

if [ -z "$destination" ]; then
    destination="/tmp/manual"
fi

if [ -z "$formats" ]; then
    #formats="html pdf ps txt"
    formats="html pdf txt"
fi

[ -e "$destination" ] || mkdir -p "$destination"

if [ "$official_build" ]; then
    # Propagate this to children.
    export official_build
fi

for lang in $languages; do
    echo "Language: $lang";
    for arch in $architectures; do
        echo "Architecture: $arch"
        if [ -n "$noarchdir" ]; then
                destsuffix="$lang"
        else
                destsuffix="${lang}.${arch}"
        fi
        ./buildone.sh "$arch" "$lang" "$formats"
        mkdir -p "$destination/$destsuffix"
        for format in $formats; do
            if [ "$format" = html ]; then
                mv ./build.out/html/* "$destination/$destsuffix"
            else
                # Do not fail because of missing PDF support for some languages
                mv ./build.out/install.$lang.$format "$destination/$destsuffix" || true
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
