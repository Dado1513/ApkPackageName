#!/bin/bash

declare -A foundPackageNames
declare -A packagesNotExplored

packagesNotExplored[com.whatsapp]=1
packagesNotExplored[com.facebook.katana]=1
packagesNotExplored[com.spotify.music]=1

getMorePackageNames() {
    local output="$(lynx --dump -nonumbers \
    "https://play.google.com/store/apps/details?id=$1"\
    | sort | uniq | grep -oP "(?<=://play.google.com/store/apps/details\?id=)[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+" | sort | uniq)"

    echo "${output}"
}


# La "profondità" di esplorazione dei nomi dei package (per ogni package ne ho altri N, quindi crescita esponenziale).
for i in {1..1000000}; do
    # Per ogni nome di package non ancora esplorato...
    for key in "${!packagesNotExplored[@]}"; do
        while read -r line; do
            if ! [ -z "${line// }" ] && ! [ ${foundPackageNames["${line}"]+_} ]; then
                # Se è la prima volta che trovo il nome di questo package, lo aggiungo alla lista dei
                # nomi dei package trovati e alla lista dei package da esplorare (per trovare app correlate).
                foundPackageNames["${line}"]=1;
                packagesNotExplored["${line}"]=1;
                echo "${line}"
                echo "${line}" >> playstore_packages.txt
            fi
        done <<< "$(getMorePackageNames "${key}")"
        # Ho espolorato il package, posso rimuoverlo dalla lista.
        unset packagesNotExplored["${key}"]
    done
done

echo "Crawling completed"