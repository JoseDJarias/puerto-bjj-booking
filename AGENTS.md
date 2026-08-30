# Puerto BJJ Platform - Guía de Desarrollo y Reglas (AGENTS.md)

Este documento define el stack tecnológico, las reglas de arquitectura y las políticas estrictas de desarrollo (TDD y Prevención de N+1) para el proyecto "Puerto BJJ Platform".

## 1. Stack Tecnológico
- **Framework:** Ruby on Rails (> 7.1)
- **Base de Datos:** SQLite3 (Sharding en producción: Primary, Cache, Queue, Cable con gemas Solid)
- **Frontend:** TailwindCSS, Hotwire (Turbo & Stimulus), Diseño minimalista.
- **Despliegue:** Kamal 2.x apuntando a servidores Hetzner (CPX11).
- **Almacenamiento (Storage):** Cloudflare R2 para almacenamiento de videos y CDN rápido/gratuito.
- **Suscripciones y Pagos:** Gema `pay` utilizando Paddle.
- **Autenticación:** Autenticación Nativa de Rails 8 (`has_secure_password`).
- **Dominios:** `platform.puertojiujitsu.com` (Producción) y `staging.platform.puertojiujitsu.com` (Staging).

## 2. Arquitectura (Rails Way)
- **Modelos Inteligentes (Smart Models):** Toda la lógica de negocio, validaciones y scopes debe residir aquí. Cero lógica de presentación.
- **Controladores Delgados (Slim Controllers):** Los controladores sólo delegan, responden a solicitudes, y siempre previenen N+1 queries (ver sección abajo).
- **Servicios:** Usar Service Objects bien intencionados para lógica compleja o de orquestación (ej: Webhooks de Paddle, procesamiento de video) que ensucie el modelo.

## 3. Internacionalización Estricta (i18n)
- **Cero Strings Hardcodeados (NO HARDCODED STRINGS):** Está absolutamente prohibido incluir texto o strings en bruto en vistas, modelos, controladores, servicios ¡y hasta en los tests! 
- Toda cadena de texto debe estar definida en los archivos de locale. 
- **OBLIGATORIO:** Cada vez que se agregue una nueva llave de traducción, debe ser añadida simultáneamente y con la misma estructura tanto en `config/locales/es.yml` (Español) como en `config/locales/en.yml` (Inglés).
- Utilizar métodos como `t()` o `I18n.t()` en lugar de texto plano.

## 4. Test Driven Development (TDD) y "Bullet Proof" Code
- **Tests Rigurosos:** Todo desarrollo debe ser guiado por pruebas y pensar en cómo hacer fallar la aplicación.
- **Estructura de Datos:** El primer paso en cualquier test es validar las estructuras de datos que retorna un controlador, modelo o servicio.
- **Happy & Wrong Cases:** Se deben probar tanto los caminos felices como los casos de fallo. ¿Cómo se rompe el código? ¿Qué pasa si un atributo viene nulo (nil)? Todo debe estar probado.
- **Bullet:** En el entorno `test`, Bullet está configurado para levantar un error inmediatamente si se detecta un N+1, haciendo que las pruebas fallen.

## 5. Prevención de N+1 Queries (Performance Guarantees)
Esta aplicación previene de manera estricta los queries N+1.
- Toda iteración sobre colecciones en vistas MUST utilizar `.includes` en el controlador para pre-cargar las asociaciones.
- Se debe usar `assoc.size`, `assoc.any?` o `assoc.to_a.count` en memoria, en lugar de `count`, `exists?` o queries SQL dentro de bloques iterativos que ya han sido eager-loaded.
- Todo test de integración de controladores debe usar `assert_queries(numero_esperado) { ... }` para verificar que la ejecución se mantenga limpia.

> *Revisa la guía `test/README_N_PLUS_ONE.md` para más información sobre cómo auditar y probar la carga agresiva (eager loading).*
