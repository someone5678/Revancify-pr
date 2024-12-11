#!/usr/bin/bash

chooseApp() {
    local PREVIOUS_APP EXIT_CODE
    fetchAssets || return 1
    unset PKG_NAME APP_NAME APKMIRROR_APP_NAME DEVELOPER_NAME
    PREVIOUS_APP="$SELECTED_APP"
    SELECTED_APP=$("${DIALOG[@]}" \
        --title '| App Selection Menu |' \
        --no-tags \
        --ok-label 'Select' \
        --cancel-label 'Back' \
        --help-button \
        --help-label 'Import' \
        --default-item "$SELECTED_APP" \
        --menu "$NAVIGATION_HINT" -1 -1 0 \
        "${APPS_LIST[@]}" \
        2>&1 > /dev/tty
    )
    EXIT_CODE=$?
    case "$EXIT_CODE" in
    0)
        source <(jq -nrc --argjson SELECTED_APP "$SELECTED_APP" '
            $SELECTED_APP |
            "PKG_NAME=\(.pkgName)
            APP_NAME=\(.appName)
            APKMIRROR_APP_NAME=\(.apkmirrorAppName)
            DEVELOPER_NAME=\(.developerName)"
        ')
        TASK="DOWNLOAD_APP"
        ;;
    1)
        return 1
        ;;
    2)
        TASK="IMPORT_APP"
        ;;
    esac
    [ "$PREVIOUS_APP" != "$SELECTED_APP" ] && unset VERSIONS_LIST
    return 0
}
