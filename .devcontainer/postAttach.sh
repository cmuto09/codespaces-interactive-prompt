#!/usr/bin/env bash

REPO_API_RESP=$(gh api -H "Accept: application/vnd.github+json" https://api.github.com/repos/"$GITHUB_REPOSITORY")
REPO_ID=$(jq -rc '.id' <<< $REPO_API_RESP)

USER_ENCRYPTION_KEY_API_RESP=$(gh api -H "Accept: application/vnd.github+json" /user/codespaces/secrets/public-key)
USER_ENCRYPTION_KEY_ID=$(jq -rc '.key_id' <<< $USER_ENCRYPTION_KEY_API_RESP)

SECRETS_API_RESP=$(gh api -H "Accept: application/vnd.github+json" user/codespaces/secrets)
POSSIBLY_VISIBLE_SECRETS=$(jq -rc '.secrets | map(select(.visibility == "all" or .visibility == "selected"))' <<< $API_RESP)
ACTUALLY_VISIBLE_SECRETS=()
for row in $(jq -rc '.[]' <<< $POSSIBLY_VISIBLE_SECRETS); do
    SECRET_NAME=$(echo $row | jq -rc '.name')
    REPO_VISIBILITY=$(echo $row | jq -rc '.visibility')
    if [[ $REPO_VISIBILITY == "all" ]]; then
        $ACTUALLY_VISIBLE_SECRETS+=$SECRET_NAME
    else
        AVAILABLE_REPOS=$(gh api -H "Accept: application/vnd.github+json" "user/codespaces/secrets/$SECRET_NAME/repositories")
        SECRET_AVAILABLE_TO_THIS_REPOSITORY=$(jq -rc ".repositories | any(.full_name == \"$GITHUB_REPOSITORY\")" <<< $AVAILABLE_REPOS)
        if [[ $SECRET_AVAILABLE_TO_THIS_REPOSITORY == "true" ]]; then
            ACTUALLY_VISIBLE_SECRETS+=$SECRET_NAME
        fi
    fi
done
echo $ACTUALLY_VISIBLE_SECRETS

if [[ "${ACTUALLY_VISIBLE_SECRETS[*]}" =~ "FOO_BAR" ]]; then
    echo "Secret for FOO_BAR found. Skipping."
fi

if [[ ! "${ACTUALLY_VISIBLE_SECRETS[*]}" =~ "MY_SPECIAL_TOKEN" ]]; then
    echo "Could not find a value for MY_SPECIAL_TOKEN. Please enter it now:"
    read SPECIAL_TOKEN_VALUE
    PAYLOAD=$(jq -n --arg secret_value "$SPECIAL_TOKEN_VALUE" --arg key_id "$USER_ENCRYPTION_KEY_ID" --arg repo_id "$REPO_ID" '{"encrypted_value": $secret_value, "key_id": $key_id, "selected_repository_ids":[$repo_id]}')
    echo $PAYLOAD | gh api --method PUT -H "Accept: application/vnd.github+json" /user/codespaces/secrets/MY_SPECIAL_TOKEN --input -
fi

echo "What is your name?"
read name
echo "$name, what is your favorite color?"
read favorite_color
echo "See ya!"
echo "$name, should I show you your secrets?"
read view_secrets
if [[ $view_secrets == "y" ]]; then
    echo "Cool cool cool"
    gh api -H "Accept: application/vnd.github+json" /user/codespaces/secrets
else
    echo "Fine, don't tell me."
fi