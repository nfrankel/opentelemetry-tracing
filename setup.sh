#/bin/sh
helm upgrade --install vcluster vcluster/vcluster --namespace otel --create-namespace  --values vcluster.yaml

helm upgrade --install otel-infra infra --values infra/values.yaml --namespace otel

helm upgrade --install otel-apps apps --values apps/values.yaml
