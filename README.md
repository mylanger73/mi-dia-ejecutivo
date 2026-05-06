# Mi Día Ejecutivo · Despliegue

App web personal para gestionar pendientes diarios.
Stack: HTML estático + Supabase (auth + base de datos) + Vercel (hosting).

## Arquitectura

```
[Tu navegador (cualquier dispositivo)]
        |
        v
[Vercel]  ← sirve el HTML/CSS/JS estático
        |
        v
[Supabase] ← guarda tareas, historial, settings (con login por email)
```

- **Sin servidor propio**: el HTML corre 100% en tu navegador.
- **Sync entre dispositivos**: tus datos viven en Supabase.
- **Login sin contraseña**: enlace mágico al email.
- **Privado**: Row Level Security garantiza que cada usuario solo ve sus datos.
- **Costo**: $0 mientras estés bajo el plan gratuito de Vercel + Supabase (sobra para uso personal).

## Archivos

- `index.html` — la app
- `config.js` — URL y anon key de tu Supabase (debes editarlo)
- `supabase-setup.sql` — script para crear tablas y políticas en Supabase
- `README.md` — esta guía

## Pasos para desplegar

### 1. Crear el proyecto en Supabase

1. Entra a [supabase.com](https://supabase.com) → New project.
2. Nombre: `mi-dia-ejecutivo`. Región: la más cercana (ej. South America).
3. Define una contraseña para la base de datos (guárdala, no la usarás para la app).
4. Espera 1-2 minutos a que esté listo.

### 2. Crear las tablas

1. En el menú lateral del dashboard de Supabase, abre **SQL Editor** → **New query**.
2. Abre `supabase-setup.sql`, copia TODO el contenido.
3. Pégalo en el editor y haz clic en **Run**.
4. Deberías ver "Success. No rows returned." en verde.

### 3. Configurar el email login

1. En Supabase, ve a **Authentication** → **Providers**.
2. Verifica que **Email** esté habilitado (viene por defecto).
3. Opcional: en **Authentication** → **Email Templates** → **Magic Link**, traduce el email al español si quieres.
4. Más adelante, después del paso 6, vuelve aquí y agrega tu URL de Vercel a **Authentication** → **URL Configuration** → **Site URL** y **Redirect URLs**.

### 4. Copiar URL y anon key a `config.js`

1. En Supabase: **Project Settings** → **API**.
2. Copia el valor de **Project URL** (ej: `https://abcdefgh.supabase.co`).
3. Copia el valor de **Project API keys → anon (public)**.
4. Abre `config.js` y reemplaza los placeholders:

```js
window.SUPABASE_URL = 'https://abcdefgh.supabase.co';
window.SUPABASE_ANON_KEY = 'eyJhbGciOi...tu key completa...';
```

> **No te preocupes** por exponer la anon key públicamente: es de uso público por diseño. La seguridad real está en las políticas RLS que ya configuraste.

### 5. Subir a GitHub

Opción A — desde la web:
1. En github.com, haz clic en **New repository**.
2. Nombre: `mi-dia-ejecutivo`. Privado o público (cualquiera funciona).
3. Sin README, sin .gitignore (vienen vacíos).
4. En la página del repo nuevo, haz clic en **uploading an existing file**.
5. Arrastra los 3 archivos: `index.html`, `config.js`, `supabase-setup.sql`. (El README es opcional.)
6. Commit.

Opción B — desde la terminal (si tienes git):
```bash
cd "C:\Users\Marcelo Yañez\OneDrive - Intertrade\çccF3çćc\Claude\Projects\App pendientes diarios\deploy"
git init
git add .
git commit -m "Mi Día Ejecutivo v1"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/mi-dia-ejecutivo.git
git push -u origin main
```

### 6. Desplegar en Vercel

1. Entra a [vercel.com](https://vercel.com) → **Add New** → **Project**.
2. Importa el repositorio `mi-dia-ejecutivo` desde GitHub.
3. Framework Preset: **Other** (es HTML puro).
4. Root Directory: déjalo en blanco (raíz del repo).
5. Build & Output Settings: déjalo en blanco (no hay build).
6. Click **Deploy**. En 30-60 segundos tendrás una URL tipo `https://mi-dia-ejecutivo.vercel.app`.

### 7. Conectar Vercel ↔ Supabase

Vuelve a Supabase → **Authentication** → **URL Configuration**:
- **Site URL**: pega tu URL de Vercel (ej: `https://mi-dia-ejecutivo.vercel.app`).
- **Redirect URLs**: agrega también esa misma URL (con y sin `/`).

Esto autoriza que Supabase mande el enlace mágico a esa URL.

### 8. Probar

1. Abre tu URL de Vercel.
2. Ingresa tu email y haz clic en **Enviar enlace**.
3. Revisa tu email (puede llegar como "Magic Link"). Haz clic en el enlace.
4. Vuelves a la app, ya logueado. Empieza a anotar pendientes.
5. Abre la misma URL en tu celular, ingresa el mismo email, y verás los mismos datos.

## Mantenimiento y respaldo

### Respaldo automático
Supabase respalda la base de datos automáticamente (en plan gratuito: 7 días de retención).
Para descargar un dump manualmente: **Database** → **Backups**.

### Actualizar la app
Cualquier cambio que hagas en el código y subas a GitHub se redespliega automáticamente en Vercel (en ~30 segundos).

### Ver/editar tus datos directamente
En Supabase → **Table Editor** puedes ver y modificar las filas a mano si necesitas.

### Costo estimado (uso personal)
- Vercel Hobby: gratis
- Supabase Free: gratis (500 MB DB, 1 GB storage, 50k MAUs — sobra de sobra)

## Troubleshooting

**El email no llega**
- Revisa spam.
- En Supabase → **Logs** → **Auth Logs** verifica que se mandó.
- En plan gratuito Supabase usa su propio SMTP con límites: 4 emails/hora por dirección, ~30/hora total. Para producción, configura SMTP propio (SendGrid, Resend, etc.).

**"Configuración faltante" al abrir la app**
- Revisa que editaste `config.js` correctamente y subiste el cambio.
- En Vercel, fuerza un redeploy si es necesario.

**El enlace mágico me lleva pero no me loguea**
- Verifica que la URL de Vercel esté en **Site URL** Y en **Redirect URLs** de Supabase.

**No veo mis tareas en otro dispositivo**
- Asegúrate de loguearte con el MISMO email en ambos.

## Para usar localmente (sin desplegar)
Como `file://` no funciona bien con auth, usa un servidor local mínimo:
```bash
cd deploy
python -m http.server 8000
# o:  npx serve .
```
Luego abre http://localhost:8000 (y agrega esa URL a las Redirect URLs de Supabase).
