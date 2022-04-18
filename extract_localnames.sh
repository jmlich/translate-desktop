#!/bin/bash

declare -A list=(
    [glacier-alarmclock]='string(//context[name="QObject"]/message[source="Clock"]/translation)'
    [glacier-browser]='string(//context[name="MainPage"]/message[source="Browser"]/translation)'
    [glacier-calc]='string(//context[name="glacier-calc"]/message[source="Calculator"]/translation)'
    [glacier-camera]='string(//context[name="CameraPage"]/message[source="Camera"]/translation)'
    [glacier-contacts]='string(//context[name="QObject"]/message[source="Contacts"]/translation)'
    [glacier-dialer]='string(//context[name="FirstPage"]/message[source="Dialer"]/translation)'
    [glacier-filemuncher]='string(//context[name="QObject"]/message[source="Files browser"]/translation)'
    [glacier-gallery]='string(//context[name="QObject"]/message[source="Gallery"]/translation)'
    [glacier-music]='string(//context[name="PlayerPage"]/message[source="Music"]/translation)'
    [glacier-packagemanager]='string(//context[name="QObject"]/message[source="Packages"]/translation)'
    [glacier-settings]='string(//context[name="QObject"]/message[source="Settings"]/translation)'
    [glacier-testtool]='string(//context[name="QObject"]/message[source="Hardware test"]/translation)'
    [glacier-weather]='string(//context[name="MainPage"]/message[source="Weather"]/translation)'
    [glacier-messages]='string(//context[name="QObject"]/message[source="Messages"]/translation)'
    [glacier-calendar]='string(//context[name="QObject"]/message[source="Calendar"]/translation)'
)

cd ..

for repo in ${!list[@]}; do
    query="${list[$repo]}"

    cd ./$repo
        git fetch --all --tags
        git merge upstream/master
#        git reset upstream/master
        ts=$(find . -name "$repo.ts")
        lupdate . -recursive -ts "$ts"
    cd ..

    desktop_file=$(find $repo -name "$repo"'.desktop')
    count=0

    for fn in $(find $repo -name '*.ts' ! -name '*depend*' -type f); do
        lang=$(xmllint --xpath 'string(//TS/@language)' "$fn") #'
        if [ -z "$lang" ]; then
            continue
        fi

        local_name=$(xmllint --xpath "$query" "$fn")
#        echo "$repo Name[$lang]=$local_name"

        if [ -z "$local_name" ]; then
            continue
        fi

        if ! grep -q "^Name\[$lang\]=" $desktop_file; then
            echo "Appending $repo / $lang"
            echo "Name[$lang]=$local_name" >> $desktop_file
        else
            sed 's/^Name\['"$lang"'\]=.*/Name['"$lang"']='"$local_name"'/g' -i "$desktop_file"
        fi

        count=$((count + 1))

    done

    if [ $count -le 0 ]; then
        echo "nothing in $repo"
    fi

done
