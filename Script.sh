#!/bin/bash
# -------------------------------------------
# Script: deploy.sh
# Despliegue automático - 0505AT - Script de Despliegue - ITU UNCuyo
# Autor: Juan Cruz (con ayudita de ChanguITU)
# Fecha: 2025-04-28
# Descripción: Automatiza el despliegue de una web estática en Minikube con verificaciones completas
# -------------------------------------------

set -euo pipefail

# --- Configuración ---
WORKDIR="${1:-$HOME/Trabajo-Cloud}"
REPO_WEB="https://github.com/Juan95Kruz/static-website.git"
REPO_INFRA="https://github.com/Juan95Kruz/Infraestructura.git"
MOUNT_SOURCE="$WORKDIR/static-website"
MOUNT_TARGET="/mnt/web"
MANIFESTS_DIR="$WORKDIR/Infraestructura/k8s-manifiestos"

# --- Funciones auxiliares ---
function validar_dependencias() {
    echo "🔍 Validando dependencias..."
    for cmd in git minikube kubectl curl; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "❌ Error: '$cmd' no encontrado. Instálalo antes de continuar."
            exit 1
        fi
    done
}

function clonar_repositorios() {
    echo "📥 Clonando repositorios..."
    mkdir -p "$WORKDIR"
    cd "$WORKDIR"

    [ ! -d "static-website" ] && git clone "$REPO_WEB" || echo "📂 Repositorio 'static-website' ya existe, omitiendo clonado."
    [ ! -d "Infraestructura" ] && git clone "$REPO_INFRA" || echo "📂 Repositorio 'Infraestructura' ya existe, omitiendo clonado."
}

function iniciar_minikube() {
    echo "🚀 Iniciando Minikube..."
    if ! minikube status &>/dev/null; then
        minikube start --driver=docker --mount --mount-string="$MOUNT_SOURCE:$MOUNT_TARGET"
    else
        echo "⚙️ Minikube ya está corriendo."
    fi
}

function habilitar_ingress() {
    echo "🌐 Verificando estado del addon Ingress..."
    minikube addons enable ingress 2>/dev/null || echo "✅ Addon 'ingress' ya estaba habilitado."
}

function esperar_ingress_ready() {
    echo "⏳ Esperando que el Ingress Controller esté listo..."
    kubectl rollout status deployment ingress-nginx-controller -n ingress-nginx --timeout=180s
    echo "✅ Ingress Controller listo."
}

function aplicar_manifiestos() {
    echo "📜 Aplicando manifiestos de Kubernetes..."
    kubectl apply -f "$MANIFESTS_DIR/volumenes/pv.yaml"
    kubectl apply -f "$MANIFESTS_DIR/volumenes/pvc.yaml"
    kubectl apply -f "$MANIFESTS_DIR/deployment/deployment.yaml"
    kubectl apply -f "$MANIFESTS_DIR/service/service.yaml"
    kubectl apply -f "$MANIFESTS_DIR/ingress/ingress.yaml"
}

function verificar_todos_los_recursos() {
    echo "🔍 Verificando todos los recursos del cluster..."

    for pv in $(kubectl get pv -o jsonpath='{.items[*].metadata.name}'); do
        echo "🔄 Verificando PV '$pv'..."
        kubectl wait pv "$pv" --for=phase=Bound --timeout=120s
    done

    for pvc in $(kubectl get pvc -o jsonpath='{.items[*].metadata.name}'); do
        echo "🔄 Verificando PVC '$pvc'..."
        kubectl wait pvc "$pvc" --for=condition=Bound --timeout=120s
    done

    for deploy in $(kubectl get deploy -o jsonpath='{.items[*].metadata.name}'); do
        echo "🔄 Verificando Deployment '$deploy'..."
        kubectl rollout status deploy "$deploy" --timeout=180s
    done

    for svc in $(kubectl get svc -o jsonpath='{.items[*].metadata.name}'); do
        echo "🔄 Verificando Service '$svc'..."
        kubectl get svc "$svc"
    done

    for ing in $(kubectl get ingress -o jsonpath='{.items[*].metadata.name}'); do
        echo "🔄 Verificando Ingress '$ing'..."
        kubectl get ingress "$ing"
    done

    echo "✅ Todos los recursos verificados correctamente."
}


function configurar_hosts() {
    echo "🌐 Configurando acceso a sitio.local..."
    IP_MINIKUBE=$(minikube ip)

    if grep -q "sitio.local" /etc/hosts; then
        echo "⚙️ 'sitio.local' ya existe en /etc/hosts."
    else
        echo "🔧 Agregando 'sitio.local' a /etc/hosts..."
        echo "$IP_MINIKUBE sitio.local" | sudo tee -a /etc/hosts >/dev/null
        echo "✅ Agregado exitosamente."
    fi
}

function verificar_pagina() {
    echo "🌍 Verificando que la página esté disponible..."
    for i in {1..10}; do
        if curl -s -o /dev/null -w "%{http_code}" http://sitio.local/ | grep -q "200"; then
            echo "✅ Página responde correctamente (HTTP 200)."
            return
        else
            echo "⏳ Esperando que la página responda... ($i/10)"
            sleep 5
        fi
    done
    echo "❌ La página no respondió correctamente tras varios intentos."
    exit 1
}

# --- Ejecución principal ---
echo "🌟 Script de despliegue iniciado..."

validar_dependencias
clonar_repositorios
iniciar_minikube
habilitar_ingress
esperar_ingress_ready
aplicar_manifiestos
verificar_todos_los_recursos
configurar_hosts
verificar_pagina

echo ""
echo "🎉 ¡Despliegue completado exitosamente!"
echo "👉 Accedé a tu sitio en: http://sitio.local/"

