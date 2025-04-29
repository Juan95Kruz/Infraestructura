# 🚀 Trabajo 0311AT - Despliegue de Página Web Estática en Minikube

Hola! Soy Juan95Kruzy en este proyecto te voy a mostrar cómo desplegar una página web estática usando Minikube, Kubernetes y un volumen persistente.  
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

- Acordate de reemplazar `kruz` por tu nombre de usuario si usás otro.
- Podés modificar los manifiestos (`deployment.yaml`, `service.yaml`, etc.) si querés ajustar algo de la configuración.

---

# 🖥️ Autor

- **Juan Cruz** | [GitHub](https://github.com/Juan95Kruz)

---
