# 🚀 Trabajo 0311AT - Despliegue de Página Web Estática en Minikube

Este proyecto despliega una página web estática en Minikube utilizando Kubernetes y un volumen persistente. El contenido se sincroniza con un repositorio de GitHub y se sirve mediante Nginx.

---

## 📋 Requisitos

- **Minikube**: [Guía de instalación oficial](https://minikube.sigs.k8s.io/docs/).
- **Kubectl**: [Guía de instalación oficial](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- **Docker**: Necesario si utilizas el driver Docker para Minikube.

---

## 🛠️ Pasos para desplegar el entorno

### 1. Clonar los repositorios

Crea una carpeta para trabajar y clona los repositorios:

```bash
mkdir ~/Trabajo-Cloud
cd ~/Trabajo-Cloud
git clone https://github.com/Juan95Kruz/static-website.git
git clone https://github.com/Juan95Kruz/Infraestructura.git
```

Estructura esperada:

```
/home/kruz/Trabajo-Cloud
├── Infraestructura
│   └── k8s-manifiestos
│       ├── deployment
│       │   └── deployment.yaml
│       ├── ingress
│       │   └── ingress.yaml
│       ├── service
│       │   └── service.yaml
│       └── volumenes
│           ├── pvc.yaml
│           └── pv.yaml
├── static-website
│   ├── assets
│   ├── index.html
│   └── style.css
└── README.txt
```

---

### 2. Iniciar Minikube con montaje de directorio

Inicia Minikube montando el contenido estático:

```bash
minikube start --driver=docker --mount --mount-string="/home/kruz/Trabajo-Cloud/static-website:/mnt/web"
```

---

### 3. Aplicar los manifiestos de Kubernetes

Aplica los recursos necesarios:

```bash
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/volumenes/pv.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/volumenes/pvc.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/deployment/deployment.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/service/service.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/ingress/ingress.yaml
```

---

### 4. Verificar recursos desplegados

Consulta el estado de los pods y servicios:

```bash
kubectl get pods
kubectl get services
```

✅ Asegúrate de que los pods estén en estado `Running` y el servicio correctamente expuesto.

---

### 5. Habilitar Ingress

Activa el complemento de Ingress en Minikube:

```bash
minikube addons enable ingress
```

Verifica el estado:

```bash
kubectl get ingress
```

---

### 6. Configurar el archivo `/etc/hosts`

Asocia el dominio `sitio.local` a la IP de Minikube:

```bash
echo "$(minikube ip) sitio.local" | sudo tee -a /etc/hosts
```

---

### 7. Acceder a la página web

Abre en tu navegador:

```text
http://sitio.local/
```

¡Deberías ver tu página web estática servida por Nginx! 🌐

---

## 📎 Notas

- Si cambias el usuario (`kruz`) o la ubicación del proyecto, asegúrate de actualizar las rutas en los comandos.
- Puedes modificar los manifiestos YAML según tus necesidades específicas.

---

## 🖥️ Autor

- **Juan95Kruz** | [GitHub](https://github.com/Juan95Kruz)

---
