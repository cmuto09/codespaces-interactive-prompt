#!/usr/bin/env bash
if [[ -z "$MY_SPECIAL_TOKEN" ]]; then
        echo "Could not find a value for MY_SPECIAL_TOKEN. Please enter it now:"
        read SPECIAL_TOKEN_VALUE
        echo -n $SPECIAL_TOKEN_VALUE | gh secret set --user MY_SPECIAL_TOKEN --repos "$GITHUB_REPOSITORY"
    else
        echo "Found MY_SPECIAL_TOKEN"
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