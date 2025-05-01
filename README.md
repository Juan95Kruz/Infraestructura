<<<<<<< HEAD
# 🚀 Trabajo 0311AT - Despliegue de Página Web Estática en Minikube

Hola! Soy Juan95Kruz y en este proyecto te voy a mostrar cómo desplegar una página web estática usando Minikube, Kubernetes y un volumen persistente.  
El contenido de la página está sincronizado con un repositorio de GitHub y se sirve a través de Nginx. 🚀

---

# 📋 Requisitos

Antes de empezar, asegurate de tener instalado lo siguiente:

- **Minikube**: [Guía de instalación](https://minikube.sigs.k8s.io/docs/).
- **Kubectl**: [Guía de instalación](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- **Docker**: [Guía de instalación](https://docs.docker.com/get-docker/) (lo vas a necesitar si usás el driver Docker para Minikube).

---

# 🛠️ Pasos para desplegar el entorno

## 1. Clonar los repositorios

Primero creamos una carpeta para trabajar y clonamos los repos:

```bash
mkdir ~/Trabajo-Cloud
cd ~/Trabajo-Cloud
git clone https://github.com/Juan95Kruz/static-website.git
git clone https://github.com/Juan95Kruz/Infraestructura.git
```

Así debería verse la estructura:

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

## 2. Iniciar Minikube montando el directorio

Después vamos a levantar Minikube montando la carpeta de la página web:

```bash
minikube start --driver=docker --mount --mount-string="/home/kruz/Trabajo-Cloud/static-website:/mnt/web"
```

---

## 3. Aplicar los manifiestos de Kubernetes

Ahora aplicamos todos los manifiestos para desplegar los recursos:

```bash
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/volumenes/pv.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/volumenes/pvc.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/deployment/deployment.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/service/service.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/ingress/ingress.yaml
```

---

## 4. Verificar que todo esté corriendo

Podés chequear el estado de los pods y servicios así:

```bash
kubectl get pods
kubectl get services
```

✅ Asegurate de que los pods estén en estado `Running` y que los servicios estén expuestos correctamente.

---

## 5. Habilitar el Ingress Controller

Si todavía no lo habilitaste, activá el addon de Ingress en Minikube:

```bash
minikube addons enable ingress
```

Y después verificá:

```bash
kubectl get ingress
```

---

## 6. Configurar `/etc/hosts`

Agregamos una entrada en `/etc/hosts` para poder acceder fácilmente:

```bash
echo "$(minikube ip) sitio.local" | sudo tee -a /etc/hosts
```

Esto permite entrar con el nombre `sitio.local` en el navegador.

---

## 7. Acceder a la página web

Ahora sí, abrí tu navegador y entrá a:

```text
http://sitio.local/
```

🎉 ¡Y listo! Deberías ver tu página servida por Nginx con el contenido de tu repositorio.

---

# 📎 Notas finales

- Acordate de reemplazar `kruz` por tu nombre de usuario si usas otro, también no te olvides de usar el nombre de tu carpeta creada.
- Podes modificar los manifiestos (`deployment.yaml`, `service.yaml`, etc.) si querés ajustar algo de la configuración.

---

# 🖥️ Autor

- **Juan Cruz** | [GitHub](https://github.com/Juan95Kruz)

---
=======

# 🚀 Trabajo 0311AT - Despliegue de Página Web Estática en Minikube

Hola! Soy Juan95Kruz y en este proyecto te voy a mostrar cómo desplegar una página web estática usando Minikube, Kubernetes y un volumen persistente.  
El contenido de la página está sincronizado con un repositorio de GitHub y se sirve a través de Nginx. 🚀

---

# 📋 Requisitos

Antes de empezar, asegurate de tener instalado lo siguiente:

- **Minikube**: [Guía de instalación](https://minikube.sigs.k8s.io/docs/).
- **Kubectl**: [Guía de instalación](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- **Docker**: [Guía de instalación](https://docs.docker.com/get-docker/) (lo vas a necesitar si usás el driver Docker para Minikube).

---

# 🛠️ Despliegue Manual

## 1. Clonar los repositorios

Primero creamos una carpeta para trabajar y clonamos los repos:

```bash
mkdir ~/Trabajo-Cloud
cd ~/Trabajo-Cloud
git clone https://github.com/Juan95Kruz/static-website.git
git clone https://github.com/Juan95Kruz/Infraestructura.git
```

Así debería verse la estructura:

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
└── README.md
```

---

## 2. Iniciar Minikube montando el directorio

```bash
minikube start --driver=docker --mount --mount-string="/home/kruz/Trabajo-Cloud/static-website:/mnt/web"
```

---

## 3. Aplicar los manifiestos de Kubernetes

```bash
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/volumenes/pv.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/volumenes/pvc.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/deployment/deployment.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/service/service.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/ingress/ingress.yaml
```

---

## 4. Verificar que todo esté corriendo

```bash
kubectl get pods
kubectl get services
```

✅ Asegurate de que los pods estén en estado `Running`.

---

## 5. Habilitar el Ingress Controller

```bash
minikube addons enable ingress
kubectl get ingress
```

---

## 6. Configurar `/etc/hosts`

```bash
echo "$(minikube ip) sitio.local" | sudo tee -a /etc/hosts
```

---

## 7. Acceder a la página web

```text
http://sitio.local/
```

🎉 ¡Y listo! Deberías ver tu página servida por Nginx con el contenido de tu repositorio.

---

# 🤖 Despliegue Automático

## Script de Despliegue Automático

### Descripción

Este script automatiza todo el proceso anterior. Clona los repositorios, configura Minikube, habilita el Ingress y aplica los manifiestos.

### Requerimientos

Debés tener instalado:

- `git`
- `minikube`
- `kubectl`

Verificá con:

```bash
git --version
minikube version
kubectl version
```

O instalalos con:

```bash
sudo apt-get install git

curl -Lo minikube.deb https://storage.googleapis.com/minikube/releases/latest/minikube_$(uname -m).deb
sudo dpkg -i minikube.deb

sudo apt-get update && sudo apt-get install -y kubectl
```

### Instrucciones

1. Dar permisos:

```bash
chmod +x Script.sh
```

2. Ejecutar el script:

```bash
./Script.sh
```

🔧 El script realiza:

- Validación de dependencias
- Clonación de repositorios
- Inicio de Minikube con montaje
- Aplicación de manifiestos Kubernetes
- Habilitación de Ingress
- Configuración de `/etc/hosts`
- Acceso final en: `http://sitio.local/`

---

<<<<<<< HEAD
¡Listo para desplegar tu sitio web estático en Minikube de forma rápida y sencilla! 🌐
>>>>>>> 0735992 (Segundo commit, Añadiendo REAME.md)
=======
# 🖥️ Autor

- **Juan Cruz** | [GitHub](https://github.com/Juan95Kruz)

---
>>>>>>> b48b4d0 (Agregando Script.sh al repo y modificando README.md)
