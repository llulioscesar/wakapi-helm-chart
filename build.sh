#!bin/sh

helm package charts/*

helm repo index --url https://start-codex.github.io/wakapi-helm-chart .