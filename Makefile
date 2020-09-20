SHELL=/bin/bash
.ONESHELL:

contour-up:
	@echo "+-------------------------------------+"
	@echo "| Contour UP                          |"
	@echo "+-------------------------------------+"
	helm install contour bitnami/contour
	kubectl get service contour-envoy -o wide -w

contour-preview:
	@echo "+-------------------------------------+"
	@echo "| Contour PREVIEW                     |"
	@echo "+-------------------------------------+"
	helm template contour  bitnami/contour --output-dir ./preview

contour-down:
	@echo "+-------------------------------------+"
	@echo "| Contour DOWN                        |"
	@echo "+-------------------------------------+"
	helm delete contour

external-ip: 
	@echo "+-------------------------------------+"
	@echo "| External IP                         |"
	@echo "+-------------------------------------+"
	kubectl describe svc contour-envoy --namespace default | grep Ingress | awk '{print $3}'

certmanager-up:
	@echo "+-------------------------------------+"
	@echo "| Certmanager UP                      |"
	@echo "+-------------------------------------+"
	helm install certmanager jetstack/cert-manager -f certmanagerValues.yaml
	# I dont know a quick way to wait until all ready, therefore a lame sleep 
	sleep 20 
	kubectl apply -f letsencrypt-prod.yaml
	kubectl apply -f letsencrypt-staging.yaml

certmanager-preview:
	@echo "+-------------------------------------+"
	@echo "| Certmanager PREVIEW                 |"
	@echo "+-------------------------------------+"
	helm template certmanager jetstack/cert-manager -f certmanagerValues.yaml --output-dir ./preview

certmanager-down:
	@echo "+-------------------------------------+"
	@echo "| Certmanager DOWN                    |"
	@echo "+-------------------------------------+"
	helm delete certmanager

argocd-up:
	@echo "+-------------------------------------+"
	@echo "| ArgoCD UP                           |"
	@echo "+-------------------------------------+"
	helm install argocd argo/argo-cd -f argocdValues.yaml --namespace argocd

argocd-preview:
	@echo "+-------------------------------------+"
	@echo "| ArgoCD PREVIEW                      |"
	@echo "+-------------------------------------+"
	helm template argocd argo/argo-cd -f argocdValues.yaml --output-dir ./preview --namespace argocd

argocd-down:
	@echo "+-------------------------------------+"
	@echo "| ArgoCD DOWN                         |"
	@echo "+-------------------------------------+"
	helm delete argocd --namespace argocd

argocd-pwd:
	@echo "+-------------------------------------+"
	@echo "| ArgoCD PWD                          |"
	@echo "+-------------------------------------+"
	k get pods -n argocd | grep argocd-server | awk '{print $1}'

helm-repos: 
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add jetstack https://charts.jetstack.io
	helm repo add argo https://argoproj.github.io/argo-helm

up:
	make contour-up
	make certmanager-up
	make argocd-up

preview:
	make contour-preview
	make certmanager-preview
	make argocd-preview

down:
	make argocd-down
	make certmanager-down
	make contour-down