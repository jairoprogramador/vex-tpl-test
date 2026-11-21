# Tu Infraestructura como Plantilla, Potenciada por fastDeploy

**Convierte tus despliegues en un proceso predecible, repetible y agnóstico a la tecnología. `mydeploy` no es solo un repositorio; es el blueprint para la excelencia en DevOps, diseñado para ser un motor de referencia para `fastDeploy`.**

---

## ¿Qué es `mydeploy`?

`mydeploy` es una plantilla de despliegue que estandariza y automatiza el proceso de llevar un microservicio Java a un cluster de Azure Kubernetes Service (AKS). Pero su verdadero poder reside en su diseño: una arquitectura de "infraestructura como plantilla" que te permite abstraer la complejidad y centrarte en lo que realmente importa: el código.

Este repositorio es la implementación de referencia para [fastDeploy](https://github.com/jairoprogramador/fastdeploy), una herramienta CLI que consume plantillas como esta para orquestar despliegues complejos con comandos simples e intuitivos.

## La Filosofía: Infraestructura como Plantilla

Olvídate de los scripts frágiles y los `READMEs` de 100 pasos. La filosofía detrás de `mydeploy` es simple pero poderosa:

> **Define tu proceso de despliegue una vez. Ejecútalo miles de veces, en cualquier entorno, sin fricción.**

Centralizamos toda la lógica de despliegue —desde la verificación de herramientas hasta el aprovisionamiento de infraestructura y el despliegue final— en una estructura de pasos (`steps`) y entornos (`environments`) clara y reutilizable.

## ✨ Características que te Empoderan

*   **🚀 Despliegues Agnósticos a la Tecnología:** Aunque este ejemplo se centra en Java y AKS, la estructura de `steps` y `commands.yaml` es universal. ¿Necesitas desplegar Node.js en AWS? ¿O un servicio de Python en Google Cloud? Simplemente adapta los comandos. El framework ya está aquí.
*   **⚙️ Orquestación por Pasos (Steps):** El directorio `steps` divide el despliegue en fases lógicas y numeradas (`01-test`, `02-supply`, etc.). Cada paso es un subdirectorio autocontenido, lo que facilita la comprensión, el mantenimiento y la depuración del flujo.
*   **📄 Comandos Declarativos (`commands.yaml`):** Dentro de cada paso, el archivo `commands.yaml` define las acciones a ejecutar. Cada comando es un objeto con:
    *   `name`: Un verbo en infinitivo que describe la acción.
    *   `description`: Una explicación clara de lo que hace el comando.
    *   `cmd`: El comando de shell a ejecutar.
    *   `workdir`: (Opcional) El directorio de trabajo para la ejecución.
*   **✅ Validación y Captura de Salidas (`outputs`):** La sección `outputs` es donde la magia ocurre.
    *   **Validación de Éxito (`probe`):** Define una expresión regular para validar que la salida de un comando es la esperada. Si no coincide, el despliegue falla. ¡Adiós a los falsos positivos!
    *   **Creación Dinámica de Variables:** ¿Necesitas el ID de un recurso creado por Terraform o el nombre de un servidor? Captura valores de la salida de un comando usando grupos en tu expresión regular `probe` y asígnalos a una nueva variable. Estas variables estarán disponibles en los pasos posteriores.
*   **🌐 Gestión de Entornos (`environments.yaml`):** Define tus entornos (`sandbox`, `staging`, `production`) en un único archivo. `fastDeploy` utilizará esta configuración para dirigir los despliegues y aplicar las variables correctas.
*   **🔒 Variables por Entorno (`variables/`):** Gestiona tus configuraciones específicas de cada entorno de forma segura y organizada. El directorio `variables` contiene subdirectorios por cada entorno, permitiéndote mantener, por ejemplo, `deploy.yaml` con valores diferentes para `prod` y `sand`.
*   **📝 Plantillas Dinámicas (`templates`):** La clave para la reutilización. Define archivos (`Dockerfile`, `deployment.yaml`, etc.) con placeholders para tus variables. La directiva `templates` en un comando le indica a `fastDeploy` que reemplace las variables en esos archivos justo antes de ejecutar el comando, adaptándolos al entorno y al contexto del despliegle.

## ¿Cómo Funciona con `fastDeploy`?

`fastDeploy` es el motor que da vida a esta plantilla. Cuando un desarrollador ejecuta `fd deploy sand`:

1.  **Clona `mydeploy`:** `fastDeploy` clona este repositorio en segundo plano.
2.  **Lee la Configuración:** Analiza `environments.yaml`, los `steps` y los `variables` correspondientes al entorno `sand`.
3.  **Ejecuta los Pasos en Orden:**
    *   Comienza con `01-test`, ejecutando los comandos de `commands.yaml`.
    *   Valida las salidas con `probe`.
    *   Captura nuevas variables desde los `outputs`.
    *   Procesa las plantillas (`templates`) si se especifican.
    *   Continúa con `02-supply`, `03-package`, y así sucesivamente, pasando las variables generadas entre pasos.
4.  **Reporta el Resultado:** Informa al usuario si el despliegue fue un éxito o si falló en algún punto, proporcionando contexto claro.

## Empieza a Construir tu Propia Plantilla

Usa `mydeploy` como punto de partida. Fórkalo, adáptalo a tus tecnologías y empieza a construir una cultura de despliegues estandarizados en tu organización.

**Con `mydeploy` y `fastDeploy`, la infraestructura deja de ser un cuello de botella y se convierte en una ventaja competitiva.**

## Bootstrap de prueba (`bootstrap/azure/`)

Esta plantilla trae un bootstrap mínimo del contrato `azure/v1` para probar `vex bootstrap <ambiente>` sin desplegar nada con costo. Crea el grupo de recursos de carga (`rg-vex-<slug>-<ambiente>`), el de identidades (`rg-vex-<slug>-<ambiente>-id`) y la identidad de despliegue (`id-vex-<slug>-<ambiente>-deploy`).

| Identidad | Rol | Ámbito |
|---|---|---|
| Despliegue | Reader | Grupo de recursos de carga |

Reader es lo mínimo que deja comprobar la conexión y el canje del token: la identidad puede ver el grupo de carga y no puede cambiar nada. No crea identidad `pull` ni almacenamiento de estado, y ningún paso construye ni despliega imágenes. El único paso que recibe el token es `supply`, que enseña el grupo de recursos que entrega la conexión. Se despliega `main.json`; tras cambiar un `.bicep`, recompila con `az bicep build --file bootstrap/azure/main.bicep --outfile bootstrap/azure/main.json`.
