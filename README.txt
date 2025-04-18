
# Trabajo 0311AT - Despliegue de Página Web Estática en Minikube

Este proyecto tiene como objetivo desplegar una página web estática en Minikube, utilizando Kubernetes y un volumen persistente. La página está vinculada a un repositorio GitHub para mantener el contenido actualizado. Se utiliza Nginx como servidor web para servir los archivos estáticos.

## Requisitos

- **Minikube**: Necesario para crear y administrar el clúster de Kubernetes local. Si no lo tienes, sigue la [guía de instalación oficial](https://minikube.sigs.k8s.io/docs/).
- **Kubectl**: Herramienta de línea de comandos para interactuar con el clúster de Kubernetes. Puedes instalarla siguiendo la [guía oficial](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
- **Docker**: Si vas a usar el driver Docker para Minikube, asegúrate de tener Docker instalado en tu máquina.

## Pasos para desplegar el entorno

### 1. Clonar los repositorios

Para comenzar, necesitamos clonar dos repositorios: uno que contiene el contenido de la página web estática y otro con los manifiestos de Kubernetes.
Creamos una carpeta en donde clonaremos los repos, accedemos a esa carpeta y clonamos.

mkdir ~/Trabajo-Cloud
cd Trabajo-Cloud
git clone https://github.com/Juan95Kruz/static-website.git
git clone https://github.com/Juan95Kruz/Infraestructura.git


La estructura de las carpetas debería verse algo así:


/home/kruz/Trabajo-Cloud
├── Infraestructura
│   ├── k8s-manifiestos
│   │   ├── deployment
│   │   │   └── deployment.yaml
│   │   ├── ingress
│   │   │   └── ingress.yaml
│   │   ├── service
│   │   │   └── service.yaml
│   │   └── volumenes
│   │       ├── pvc.yaml
│   │       └── pv.yaml
│   └── README.txt
└── static-website
    ├── assets
    │   ├── banner-bg.jpg
    │   ├── banner-texture@2x.png
    │   ├── banner-texture.png
    │   ├── DSC_0036.JPG
    │   ├── img-banner@2x.png
    │   ├── img-contact-form-bg.jpg
    │   ├── img-prop-type@2x.jpg
    │   └── logo-new.png
    ├── index.html
    └── style.css



### 2. Iniciar Minikube con el montaje del directorio

A continuación, se debe iniciar Minikube con el driver Docker y montar la carpeta donde se encuentra el contenido estático de tu página web. Asegúrate de sustituir `kruz` con el nombre de la carpeta que se haya elegido, por ejemplo:


minikube start --driver=docker --mount --mount-string="/home/kruz/Trabajo-Cloud/static-website:/mnt/web"


Este comando inicia Minikube y monta el directorio local donde está la página web (`/home/kruz/Trabajo-Cloud/static-website`) en el contenedor de Minikube bajo la ruta `/mnt/web`.

### 3. Aplicar los manifiestos de Kubernetes

Una vez que Minikube esté corriendo, debemos aplicar los archivos YAML que contienen la configuración de los recursos de Kubernetes. Estos archivos definen el despliegue, el servicio y los volúmenes persistentes. Ejecuta los siguientes comandos para aplicar todos los manifiestos:

cd
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/volumenes/pv.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/volumenes/pvc.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/deployment/deployment.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/service/service.yaml
kubectl apply -f /home/kruz/Trabajo-Cloud/Infraestructura/k8s-manifiestos/ingress/ingress.yaml


Este paso configura los volúmenes persistentes, el despliegue de los pods con Nginx, el servicio para exponer la aplicación y las reglas de Ingress para acceder a la página web.

### 4. Verificar los recursos desplegados

Para asegurarte de que todo esté funcionando correctamente, se puede verificar el estado de los pods y los servicios con los siguientes comandos:


kubectl get pods
kubectl get services


Verificar que los pods estén en estado `Running` y que el servicio esté correctamente expuesto.

### 5. Habilitar Ingress

Si aún no ha habilitado el addon de Ingress en Minikube, hazlo con el siguiente comando:


minikube addons enable ingress


Y verifica el estado con:


kubectl get ingress


Este comando habilita el controlador de Ingress necesario para enrutar las solicitudes a los servicios adecuados.

### 6. Configurar el archivo `/etc/hosts`

Una vez que Ingress esté configurado y los servicios estén corriendo, vamos a añadir una entrada en el archivo `/etc/hosts` para que se pueda acceder a la página usando un nombre de dominio personalizado. Para ello, se ejecuta el siguiente comando:


echo "$(minikube ip) sitio.local" | sudo tee -a /etc/hosts


Este comando obtiene la IP de Minikube y la vincula al dominio `sitio.local` en el archivo `/etc/hosts`. De esta manera, que se podrá acceder a la aplicación en el navegador usando `sitio.local` en lugar de la IP directa de Minikube.

### 7. Acceder a la página web

Una vez realizado todo lo anterior, abre el navegador para que copiar esta url y pegarla:


http://sitio.local/


Ahora se tendría que ver la página web servida por Nginx, con el contenido que haya en la carpeta `static-website`.



