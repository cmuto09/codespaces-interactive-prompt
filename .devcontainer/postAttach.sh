#!/usr/bin/env bash

unset GITHUB_TOKEN
gh auth login -s codespace:secrets

echo "What is your name?"
read name
echo "$name, what is your favorite color?"
read favorite_color
echo "See ya!"
echo "$name, should I show you your secrets?"
read view_secrets
if [[ $view_secrets == "y" ]]; then
    echo "Cool cool cool"
    gh secret list
else
    echo "Fine, don't tell me."
fi