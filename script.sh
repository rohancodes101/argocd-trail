#!/bin/bash
set -e

echo "🚀 Starting Argo CD Setup in GitHub Codespaces..."

# 1. Install k3d if not already installed
if ! command -v k3d &> /dev/null; then
    echo "📦 Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
    echo "✅ k3d is already installed."
fi

# 2. Create k3d cluster if it doesn't exist
if ! k3d cluster list | grep -q "mycluster"; then
    echo "🌐 Creating K3s cluster 'mycluster'..."
    k3d cluster create mycluster
else
    echo "✅ Cluster 'mycluster' already exists."
fi

# 3. Create namespace and deploy Argo CD
echo "⚙️ Creating 'argocd' namespace and applying manifests..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 4. Enable insecure HTTP mode for Codespaces web proxy compatibility
echo "🔧 Configuring Argo CD server for HTTP mode (--insecure)..."
kubectl patch deployment argocd-server -n argocd --type json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--insecure"}]' 2>/dev/null || true

# 5. Wait for rollouts and pod readiness
echo "⏳ Waiting for Argo CD components to become ready..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# 6. Retrieve admin password
echo "----------------------------------------------------"
echo "🔐 ARGO CD LOGIN CREDENTIALS"
echo "Username: admin"
echo -n "Password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo -e "\n----------------------------------------------------"

# 7. Start port forwarding
echo "🌐 Starting port-forward on port 8080..."
echo "👉 Open port 8080 from the VS Code 'Ports' tab at the bottom!"
kubectl port-forward svc/argocd-server -n argocd 8080:80