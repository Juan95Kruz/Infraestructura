#!/bin/bash
# -------------------------------------------
# Script: deploy.sh
# Despliegue automático - 0505AT - Script de Despliegue - ITU UNCuyo
# Autor: Juan Cruz (con ayudita de ChanguITU)
# Fecha: 2025-04-28
# Descripción: Automatiza el despliegue de una web estática en Minikube con verificaciones completas
# -------------------------------------------

set -euo pipefail  # Hace que el script falle ante errores o variables no definidas

# --- Configuración ---
WORKDIR="${1:-$HOME/Trabajo-Cloud}"  # Carpeta de trabajo, por defecto en el home
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

    # Verifica que los PVs estén en estado Bound
    for pv in $(kubectl get pv -o jsonpath='{.items[*].metadata.name}'); do
        echo "🔄 Verificando PV '$pv'..."
        for i in {1..24}; do
            phase=$(kubectl get pv "$pv" -o jsonpath='{.status.phase}')
            if [[ "$phase" == "Bound" ]]; then
                echo "✅ PV '$pv' está Bound."
                break
            else
                echo "⏳ PV '$pv' está en fase '$phase'... esperando... ($i/24)"
                sleep 5
            fi
            if [[ $i -eq 24 ]]; then
                echo "❌ PV '$pv' no alcanzó la fase 'Bound'."
                kubectl describe pv "$pv"
                exit 1
            fi
        done
    done

    # Verifica que los PVCs estén en estado Bound
    for pvc in $(kubectl get pvc -o jsonpath='{.items[*].metadata.name}'); do
        echo "🔄 Verificando PVC '$pvc'..."
        for i in {1..24}; do
            phase=$(kubectl get pvc "$pvc" -o jsonpath='{.status.phase}')
            if [[ "$phase" == "Bound" ]]; then
                echo "✅ PVC '$pvc' está Bound."
                break
            else
                echo "⏳ PVC '$pvc' está en fase '$phase'... esperando... ($i/24)"
                sleep 5
            fi
            if [[ $i -eq 24 ]]; then
                echo "❌ PVC '$pvc' no alcanzó la fase 'Bound'."
                kubectl describe pvc "$pvc"
                exit 1
            fi
        done
    done

    # Verifica que los deployments estén listos
    for deploy in $(kubectl get deploy -o jsonpath='{.items[*].metadata.name}'); do
        echo "🔄 Verificando Deployment '$deploy'..."
        kubectl rollout status deploy "$deploy" --timeout=180s
    done

    # Muestra los services desplegados
    for svc in $(kubectl get svc -o jsonpath='{.items[*].metadata.name}'); do
        echo "🔄 Verificando Service '$svc'..."
        kubectl get svc "$svc"
    done

    # Muestra los ingress creados
    for ing in $(kubectl get ingress -o jsonpath='{.items[*].metadata.name}'); do
        echo "🔄 Verificando Ingress '$ing'..."
        kubectl get ingress "$ing"
    done

    echo "✅ Todos los recursos verificados correctamente."
}

function configurar_hosts() {
    echo "🌐 Configurando acceso a sitio.local..."
    IP_MINIKUBE=$(minikube ip)
    IP_HOSTS=$(grep "sitio.local" /etc/hosts | awk '{print $1}')

    echo "👉 IP actual de Minikube: $IP_MINIKUBE"
    echo "👉 IP en /etc/hosts: $IP_HOSTS"

    read -p "¿Querés actualizar /etc/hosts si es necesario? (s/n): " confirmacion
    if [[ $confirmacion != "s" ]]; then
        echo "🚫 Operación cancelada por el usuario."
        return
    fi

    if [ "$IP_HOSTS" == "$IP_MINIKUBE" ]; then
        echo "✅ La IP en /etc/hosts ya está actualizada."
    elif grep -q "sitio.local" /etc/hosts; then
        echo "⚙️ Actualizando IP en /etc/hosts..."
        sudo sed -i.bak "/sitio.local/c\\$IP_MINIKUBE sitio.local" /etc/hosts
        echo "✅ IP actualizada."
    else
        echo "🔧 Agregando 'sitio.local' a /etc/hosts..."
        echo "$IP_MINIKUBE sitio.local" | sudo tee -a /etc/hosts >/dev/null
        echo "✅ Agregado exitosamente."
    fi

    if command -v dig >/dev/null 2>&1; then
        IP_RESOLVED=$(dig +short sitio.local)
    else
        IP_RESOLVED=$(host sitio.local | awk '/has address/ {print $4}')
    fi

    echo "🔍 Verificación DNS: sitio.local → $IP_RESOLVED"

    if [ "$IP_RESOLVED" == "$IP_MINIKUBE" ]; then
        echo "✅ Verificación exitosa: sitio.local resuelve a $IP_MINIKUBE"
    else
        echo "⚠️ Advertencia: sitio.local no resuelve correctamente. Revisá /etc/hosts."
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

validar_dependencias      # Chequea que estén instaladas las herramientas necesarias
clonar_repositorios       # Baja los repos si no existen
iniciar_minikube          # Levanta Minikube con configuración de montaje
habilitar_ingress         # Activa Ingress si no está habilitado
esperar_ingress_ready     # Espera a que Ingress esté listo
aplicar_manifiestos       # Aplica los archivos YAML del cluster
verificar_todos_los_recursos  # Comprueba que todo esté funcionando bien
configurar_hosts          # Configura el acceso local por nombre
verificar_pagina          # Chequea que la web responda correctamente

echo ""
echo "🎉 ¡Despliegue completado exitosamente!"
echo "👉 Accedé a tu sitio en: http://sitio.local/"

