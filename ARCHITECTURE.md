# CRM Davinci — Decisiones técnicas y arquitectura

## 1) Resumen ejecutivo (por qué Flutter)

Elegimos **Flutter** porque necesitábamos una app tipo CRM con muchas pantallas, formularios y listados, y queríamos lograr una experiencia **moderna, consistente y rápida** sin duplicar esfuerzos en dos plataformas.

Flutter nos aporta:

- **Una sola base de código** para Android (y posibilidad de iOS/web si se decide a futuro).
- **Velocidad de desarrollo** (Hot Reload + componentes reutilizables).
- **UI consistente**: el diseño se ve igual en distintos dispositivos.
- **Buen rendimiento** para escenarios típicos de un CRM:
  - Listados con búsqueda/filtros/paginación.
  - Formularios largos (alta/edición).
  - Navegación frecuente entre detalle/edición/lista.
  - Estados reactivos (loading, errores, permisos por rol).
- **Ecosistema maduro** para necesidades comunes:
  - `get` (estado/navegación/DI), `shared_preferences` (persistencia de sesión), `intl` (fechas), `url_launcher` (links externos), etc.

---

## 2) Arquitectura y patrón usado (MVC vs MVVM vs MVVM-C)

En este proyecto no usamos **MVC puro** ni un **MVVM-C** estricto.

La forma más correcta de describir lo que implementamos es:

> **Arquitectura por features + capas (presentation/controller/data), usando GetX. Los Controllers funcionan como ViewModels (MVVM-like).**

### 2.1. ¿Por qué no es MVC puro?

En MVC clásico:

- La **View** renderiza.
- El **Controller** recibe eventos y decide.
- El **Model** representa datos.

En Flutter con GetX, nuestros `*Controller`:

- Mantienen **estado reactivo** (`Rx`, `Obx`).
- Orquestan la lógica (validación, filtros, permisos, llamadas a API).
- Exponen datos listos para pintar.

Eso se parece más a un **ViewModel** (MVVM) que a un controller MVC tradicional.

### 2.2. Mapeo a carpetas/clases reales del proyecto

- **View (UI)**
  - `lib/features/**/presentation/*.dart`
  - Ej: `MeetingDetailScreen`, `CreateMeetingScreen`, `LoginPage`.

- **ViewModel (GetX Controller)**
  - `lib/features/**/controllers/*_controller.dart`
  - Ej: `MeetingsController`, `LoginController`, `CustomerController`.

- **Model**
  - `lib/models/*.dart`
  - Ej: `MeetingModel`, `CustomerModel`.

- **Data Layer / Gateways / Services**
  - `lib/features/**/data/*_remote_data_source.dart`
  - `lib/core/services/*`
  - `lib/core/utils/*`
  - Ej: `MeetingsRemoteDataSource`, `AuthRemoteDataSource`, `HttpHelper`, `AuthService`.

### 2.3. ¿Y MVVM-C (Coordinator)?

En MVVM-C “puro” existe una clase `Coordinator` para navegación.

En este proyecto, la navegación está coordinada por GetX:

- `Get.to`, `Get.offAllNamed`
- `AppRoutes`
- `MainNavigationScreen`

Es decir: **hay coordinación**, pero no está formalizada como una clase `Coordinator`. Por eso es más correcto llamarlo **MVVM-like**.

---

## 3) Principios y prácticas para escalabilidad

### 3.1. Separación de responsabilidades (SRP)

- La UI no hace HTTP.
- Los Controllers no construyen URLs hardcodeadas.
- Los DataSources encapsulan llamadas a API y parsing.
- Servicios core encapsulan concerns transversales (auth, notificaciones, utilidades).

### 3.2. Centralización de endpoints y contratos

- Endpoints en `AppConstants` para evitar duplicación.
- `HttpHelper` centraliza manejo de requests, errores y casos comunes.

### 3.3. Estado reactivo (UX)

- `Rx` / `Obx` para que la UI se actualice automáticamente.
- Feedback al usuario (snackbars / confirmaciones).
- UI dependiente de permisos por rol (por ejemplo, botones de editar/eliminar).

### 3.4. Sesión, seguridad y roles

- Token/rol/email persistidos en `SharedPreferences`.
- Servicio central de auth: `AuthService`.
- Validación post-login y en bootstrap para roles permitidos.

---

## 4) Metodologías de trabajo

### 4.1. Desarrollo incremental por features

Flujo típico:

1. Endpoint backend
2. DataSource
3. Controller
4. UI
5. Ajustes UX + manejo de errores

Esto evita features “a medias” y asegura coherencia.

### 4.2. Enfoque Agile práctico

- Entregas pequeñas y verificables.
- Iteración sobre feedback real.
- Refactors puntuales cuando aparecen señales claras de deuda técnica.

### 4.3. Mantenibilidad

- Reutilización de pantallas para create/edit cuando aplica.
- Estado local coherente (update/delete sin depender solo de refresh completo).

---

## 5) Resumen “hablado” (en primera persona)

> “Elegimos Flutter porque necesitábamos una app de negocio con muchas pantallas, formularios y listados, y queríamos que se vea moderna y consistente sin duplicar el desarrollo. Con Flutter podemos mantener una sola base de código, iterar rápido y lograr una experiencia de usuario fluida.
>
> A nivel arquitectura, organizamos el proyecto por features y usamos GetX para manejar estado, navegación e inyección de dependencias. No es un MVC clásico; en la práctica es más un enfoque MVVM-like: las pantallas son la View, y los Controllers de GetX actúan como ViewModels, porque concentran el estado y la lógica de flujo. Los modelos son entidades como Meeting o Customer, y las llamadas a la API están aisladas en data sources y helpers como HttpHelper.
>
> Esto nos da escalabilidad: cada feature queda separada, el código es más fácil de mantener, y cualquier cambio de backend lo tocamos en una capa concreta sin romper toda la UI. Además, aplicamos control por roles y manejo de sesión centralizado para seguridad y consistencia en toda la app.”

---

## 6) Partes vitales de la app (módulos y cómo funcionan)

Esta app está compuesta por módulos (features) que cubren el flujo completo de un CRM. La idea clave es que cada módulo mantiene su UI y su lógica aislada, pero comparte infraestructura común (auth, HTTP, rutas, storage).

### 6.1. Navegación principal (tabs)

La app usa una navegación principal con pestañas (BottomNavigationBar) en:

- `lib/navigation/main_navigation.dart` (`MainNavigationScreen`)

Dentro se usa un `IndexedStack` para mantener el estado de cada tab:

- **Clientes**: `HomePageCustomer`
- **Proyectos**: `WorkListPage`
- **Presupuestos**: `CreateBudgetScreen`
- **Calendario / Reuniones**: `MeetingsScreen`
- **Configuración / Perfil**: `ProfileScreen`

### 6.2. Autenticación y sesión (login + persistencia)

Componentes clave:

- **Login**: `lib/features/auth/login/controllers/login_controller.dart`
- **Persistencia de sesión**: `SharedPreferences` (`auth_token`, `user_role`, `user_email`)
- **Estado global**: `lib/core/services/auth_service.dart` (`AuthService`)

Flujo resumido:

1. El usuario inicia sesión.
2. Se guarda token y rol.
3. Se navega a `MainNavigationScreen`.
4. En el arranque de la app (`main.dart`) se evalúa si hay token y si el rol es permitido.

Restricción por roles (seguridad):

- La app define roles permitidos (ej: **Admin** y **Employee**).
- Un rol **Customer** no debe ingresar a la app.
- La validación se hace tanto en:
  - **login** (para no dejar iniciar sesión), como en
  - **bootstrap** (`main.dart` / `AuthService`) para que, aunque exista un token viejo, el usuario no pueda entrar.

### 6.3. Infraestructura HTTP (cómo hablamos con el backend)

Componentes clave:

- `lib/core/constants/app_constants.dart`: endpoints centralizados.
- `lib/core/utils/http_helper.dart`: wrapper de requests.
- `lib/features/**/data/*_remote_data_source.dart`: data sources por módulo.

Responsabilidades:

- `RemoteDataSource` prepara URL, headers (incluye `Authorization: Bearer <token>`), body y parsea la respuesta.
- `HttpHelper` centraliza comportamiento transversal:
  - manejo de errores y casos no-200
  - mensajes/snackbars
  - consistencia de headers y parsing

### 6.4. Clientes (Customers)

Objetivo del módulo:

- Listar clientes, crear clientes y permitir búsqueda.

Puntos técnicos relevantes:

- Se implementa búsqueda y caching para evitar que algunos clientes “no aparezcan” hasta pasado un tiempo.
- Se mantiene una lista global (`allCustomers`) para búsquedas completas cuando hay paginación.

### 6.5. Proyectos (Works)

Objetivo del módulo:

- Listar y gestionar proyectos, con búsqueda y filtros.

Puntos técnicos relevantes:

- Búsqueda global similar a Customers para evitar inconsistencias con paginación.

### 6.6. Presupuestos (Budgets)

Objetivo del módulo:

- Crear presupuestos vinculados a clientes y (opcionalmente) proyectos.

Puntos técnicos relevantes:

- El dropdown de clientes debe cargar todos los clientes (manejo completo de paginación).
- Las dependencias entre cliente → proyectos se manejan desde el controller.

### 6.7. Reuniones (Meetings / Calendario)

Objetivo del módulo:

- Crear, ver detalle, editar, eliminar y filtrar reuniones.

Capas:

- **Model**: `MeetingModel`
- **RemoteDataSource**: `MeetingsRemoteDataSource` (GET/POST/PUT/DELETE)
- **Controller**: `MeetingsController` (estado, filtros, paginación, permisos)
- **UI**:
  - `MeetingsScreen` / `MeetingsListPage`
  - `MeetingDetailScreen`
  - `CreateMeetingScreen` (modo crear / editar)

Puntos técnicos relevantes:

- La edición se implementa reutilizando `CreateMeetingScreen` con `initialMeeting`.
- El controller actualiza la lista local tras create/update/delete y reaplica filtros/paginación.
- Acciones (editar/eliminar) se muestran/ocultan según rol.

### 6.8. Notificaciones

Componente clave:

- `lib/core/services/notification_service.dart`

Responsabilidad:

- Programar notificaciones relacionadas a reuniones.
- Reprogramar cuando cambia la lista (create/update/delete) para mantener consistencia.

---

## 7) Profundización técnica (tipo preguntas de tesis)

Esta sección cubre puntos “rebuscados” que suelen preguntar en una defensa/tesis: decisiones de arquitectura, trade-offs y cómo se asegura consistencia, seguridad y mantenibilidad.

### 7.1. ¿Cuál es la “fuente de verdad” del estado y por qué?

En una app como un CRM hay dos fuentes principales:

- **Backend**: fuente de verdad final (persistencia).
- **Estado local (front)**: necesario para UX fluida y para evitar refreshes completos.

Decisión: usamos **estado local como fuente de verdad inmediata** para la UI (optimista/controlado) y el backend como **fuente de verdad persistente**.

Ejemplo en meetings:

- Tras `create/update/delete`, el controller actualiza `meetings` y vuelve a ejecutar filtros/paginación.
- Esto evita depender de “refrescar y esperar” para que el usuario vea el cambio.

Trade-off:

- Si el backend falla, no actualizamos el estado local (flujo conservador).
- Alternativa (no usada aquí): actualizaciones 100% optimistas con rollback.

### 7.2. Consistencia, filtros y paginación: ¿por qué hay varias listas?

Para evitar complejidad en UI y mantener performance, se separa:

- `meetings`: lista completa cargada.
- `filteredMeetings`: resultado de aplicar búsqueda/filtros.
- `paginatedMeetings` (o `displayMeetings`): sublista final para render (página actual).

Invariante importante:

> Cada cambio de datos (create/update/delete o fetch) debe terminar en `_applyFilters()` → `_applyPagination()`.

Esto asegura que los cambios siempre “bajen” a la lista que realmente pinta la UI.

### 7.3. ¿Por qué GetX (reactividad) y qué riesgo tiene?

GetX se usa por:

- **Reactividad simple**: `Rx` + `Obx` actualiza UI sin boilerplate.
- **DI + navegación** sin overhead.

Riesgos típicos (y cómo mitigarlos):

- **UI que no se actualiza** si no está observando un `Rx` real.
  - Solución: usar `Obx` para variables reactivas y evitar `GetBuilder` cuando no se llama `update()`.
- **Estado duplicado** (múltiples sources de verdad) si se mezcla estado en widgets + controller.
  - Solución: reglas claras: estado de negocio vive en controller; widgets solo tienen estado efímero (TextEditingController, etc.).

### 7.4. Autenticación, roles y seguridad: ¿cómo se evita el acceso indebido?

Se aplica defensa en profundidad (“defense in depth”):

- **Validación en login**: si el backend devuelve rol no permitido, no se guarda token ni se navega a la app.
- **Validación en bootstrap**: aunque exista un token guardado, en `main.dart` / `AuthService` se revalida rol permitido antes de entrar a navegación principal.

Esto es importante porque:

- El storage local puede quedar con datos antiguos.
- Un usuario podría iniciar sesión una vez con rol distinto y luego cambiar en backend.

Limitación:

- El control final de permisos siempre debe existir también en backend. El front es una capa extra de UX/seguridad, no la autoridad.

### 7.5. Capa HTTP: ¿por qué centralizar en HttpHelper?

Centralizar HTTP resuelve problemas reales:

- Consistencia de headers (ej: `Authorization`).
- Manejo uniforme de errores.
- Evitar duplicar parsing y lógica de `success/data` en cada feature.

Punto clave para tesis:

> `HttpHelper` es un “cross-cutting concern handler”: aplica políticas transversales (errores, expiración, logging) sin repetirlas.

Trade-off:

- Si se sobrecarga `HttpHelper` con demasiada lógica, se vuelve una “caja negra”.
- Mitigación: mantener contratos claros (qué devuelve, qué hace con errores, cuándo muestra snackbar, etc.).

### 7.6. Paginación + búsqueda global: ¿por qué existe cache completa?

En listados paginados, el bug típico es:

- “No encuentro un cliente/proyecto porque está en otra página”.

Solución aplicada:

- Mantener un cache “global” (ej: `allCustomers`) para búsquedas completas.
- Ocultar/pausar paginación cuando hay búsqueda activa, para que la UI muestre resultados coherentes.

Trade-off:

- Mayor consumo de memoria si se cargan todos los registros.
- Mitigación: hacerlo bajo demanda (solo cuando se inicia búsqueda) y/o con límites.

### 7.7. Reutilización de pantallas (Create/Edit): ¿cómo se asegura precarga correcta?

Cuando se reutiliza una pantalla de create como edit, el reto real es la sincronización:

- Los dropdowns dependen de datos remotos (clientes/proyectos).
- La precarga debe ocurrir **después** de tener las listas.

Estrategia:

- Pasar `initialMeeting`.
- En `initState`, prellenar campos simples.
- En `_loadCustomers`, una vez cargada la lista, seleccionar el `customerId` de la meeting.
- Luego cargar proyectos del cliente y seleccionar `projectId`.

Esto evita el problema clásico:

- “En edit se ven vacíos cliente y proyecto aunque estén asignados”.

### 7.8. Notificaciones: ¿por qué reprogramar tras cambios?

Las notificaciones dependen del estado de meetings (fecha/hora/duración). Si una meeting cambia o se elimina:

- Una notificación programada puede quedar “fantasma”.
- O puede quedar programada para una hora incorrecta.

Estrategia aplicada:

- Reprogramar notificaciones cuando cambia la lista (create/update/delete).

Trade-off:

- Reprogramar todo puede ser más costoso.
- Alternativa: reprogramación incremental (cancelar solo la afectada y programar la nueva). Se puede implementar si la app crece.

---

## 8) Descripción corta (para README)

**“App Flutter modular por features, con arquitectura MVVM-like usando GetX (Controllers como ViewModels), capa de data sources para API, y servicios core para auth, storage y HTTP.”**

---

## 9) Preguntas de negocio (tipo tesis) basadas en este CRM

Esta sección apunta a preguntas que suelen aparecer en defensas: no son técnicas puras, sino de **valor, proceso, alcance, roles y métricas**.

### 9.1. ¿Qué problema de negocio resuelve el sistema?

Este CRM busca centralizar el ciclo comercial/operativo en un solo lugar:

- Gestión de **clientes**.
- Gestión de **proyectos/obras**.
- Creación y seguimiento de **presupuestos**.
- Planificación y seguimiento de **reuniones** (incluyendo recordatorios).

El objetivo es reducir dispersión (Excel/WhatsApp/notas) y mejorar trazabilidad.

### 9.2. ¿Cuál es el flujo de valor principal (end-to-end)?

Un flujo típico de valor es:

1. Alta/gestión de cliente.
2. Asociación a proyecto/obra.
3. Creación de presupuesto.
4. Reuniones y seguimiento (antes y después del presupuesto).
5. Cierre o continuidad (nuevo presupuesto / cambios / nuevas reuniones).

### 9.3. ¿Por qué este sistema incluye reuniones dentro del CRM?

Porque la reunión no es “solo un evento”: es parte del pipeline.

- Se contextualiza por cliente/proyecto.
- Se habilita seguimiento y trazabilidad (qué se acordó y cuándo).
- Se reducen olvidos mediante notificaciones.

### 9.4. ¿Quiénes son los usuarios y por qué existen roles?

Los roles protegen información sensible y separan responsabilidades:

- **Admin**: administración total y acciones críticas.
- **Employee**: operación diaria con permisos controlados.
- **Customer**: en este producto no ingresa (la app es interna). Se restringe para evitar exponer información interna.

En una defensa, esto se puede justificar como:

- Seguridad de datos.
- Minimización de superficie de ataque.
- Definición clara de alcance del producto.

### 9.5. ¿Qué KPIs o métricas permite medir?

Ejemplos defendibles:

- Cantidad de clientes activos.
- Proyectos activos por estado.
- Presupuestos creados por período y montos asociados.
- Reuniones programadas vs finalizadas (actividad comercial).
- Tiempo promedio desde cliente creado → primer presupuesto / primera reunión.

### 9.6. ¿Cómo mejora eficiencia o reduce costos operativos?

- Menos pérdida de información por dispersión.
- Menos reprocesos (datos reutilizados entre módulos).
- Mejor coordinación y menos ausentismo con recordatorios.
- Mayor velocidad de respuesta en seguimiento (historial centralizado).

### 9.7. ¿Qué datos son críticos y cómo se asegura calidad de datos?

Datos críticos:

- Clientes
- Proyectos
- Presupuestos
- Reuniones

La calidad se asegura con:

- Validaciones en formularios (campos requeridos, formatos).
- Relaciones consistentes (ej: proyecto asociado a cliente).
- Manejo consistente de errores para evitar estados parciales.

### 9.8. ¿Qué riesgos del negocio existen y cómo se mitigan?

Riesgos comunes:

- Exposición de información (permisos mal definidos).
- Errores operativos por datos inconsistentes.
- Baja adopción por mala UX.

Mitigaciones:

- Roles y control de acceso (además del control en backend).
- Estado local coherente para evitar “desaparición” de cambios.
- UX rápida (búsqueda/filtros, formularios claros).

### 9.9. ¿Cómo se adapta a crecimiento futuro?

Escenarios de crecimiento:

- Agregar módulos (tareas, facturación, reportes, adjuntos).
- Dashboards y analítica.
- Integraciones (WhatsApp/email automatizado).
- Más usuarios internos y permisos más granulares.

La arquitectura por features facilita extender el sistema sin reescribir lo existente.
