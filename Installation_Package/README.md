# 📡 Guía de instalación: RTL-SDR Hardware Support Package en MATLAB (Windows 10+)

Esta guía explica cómo instalar y configurar el paquete de soporte para hardware **RTL-SDR** en MATLAB, paso a paso, en sistemas Windows 10 y superiores.

---

## 🧰 Requisitos previos

Antes de comenzar, asegúrate de tener:

- ✅ MATLAB R2021b o superior  
- ✅ Acceso a Internet para descargar el paquete  
- ✅ Un dispositivo RTL-SDR USB conectado (por ejemplo, RTL2832U)  
- ✅ Permisos de instalación en Windows

---

## ⬇️ Paso 1: Abrir MATLAB y acceder a “Add-Ons”

1. Abre MATLAB.  
2. En la barra superior, haz clic en el icono de **Add-Ons** (parece una caja con un “+”).  
3. Selecciona **Get Add-Ons**.

![Abrir Add-Ons en MATLAB](./images/step1_addons.png)

---

## 📦 Paso 2: Buscar e instalar el paquete RTL-SDR

1. En la ventana que aparece, escribe **"RTL-SDR"** en el buscador.  
2. Selecciona **RTL-SDR Hardware Support Package**.  
3. Haz clic en **Install** y sigue las instrucciones.

![Buscar RTL-SDR](./images/step2_search.png)

---

## 🧪 Paso 3: Verificar la instalación

En la ventana de **Command Window** de MATLAB, ejecuta:

```matlab
sdrinfo
