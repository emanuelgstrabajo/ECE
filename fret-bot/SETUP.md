# Fret Bot — Tu IA personal nerviosita

Bot de Telegram con personalidad inspirada en Fret de Halo Infinite.
Responde con texto y notas de voz en español latino (mexicano).

**Costo: $0** — Usa Gemini (gratis) + Edge TTS (gratis)

---

## Paso 1: Crear el bot en Telegram

1. Abre Telegram y busca a **@BotFather**
2. Envía `/newbot`
3. Ponle nombre (ej: "Fret IA")
4. Ponle username (ej: "mi_fret_bot")
5. BotFather te dará un **token** — guárdalo

## Paso 2: Obtener API Key de Gemini (gratis)

1. Ve a https://aistudio.google.com/apikey
2. Inicia sesión con tu cuenta de Google
3. Click en "Create API Key"
4. Copia la key

## Paso 3: Configurar el proyecto

```bash
cd fret-bot

# Instalar dependencias
npm install

# Crear archivo de configuración
cp .env.example .env
```

Edita el archivo `.env` con tus datos:

```env
TELEGRAM_BOT_TOKEN=el_token_de_botfather
GEMINI_API_KEY=tu_api_key_de_gemini
TTS_VOICE=es-MX-DaliaNeural
```

### Voces disponibles (español mexicano):
- `es-MX-DaliaNeural` — Femenina (recomendada, muy expresiva)
- `es-MX-JorgeNeural` — Masculina

## Paso 4: Ejecutar

```bash
# Modo desarrollo (se reinicia con cambios)
npm run dev

# Modo producción
npm start
```

Deberías ver: `Fret está corriendo... (nerviosamente)`

## Paso 5: Probarlo

Abre Telegram, busca tu bot y envía `/start`

---

## Comandos del bot

| Comando | Qué hace |
|---------|----------|
| `/start` | Mensaje de bienvenida |
| `/voz [mensaje]` | Responde con texto + nota de voz |
| `/reset` | Borra el historial de conversación |
| `/help` | Muestra ayuda |

Ejemplo: `/voz qué clima hay hoy?` → Te responde con audio

---

## Hosting gratuito (opcional)

Para que el bot esté activo 24/7 sin tener tu PC encendida:

### Opción A: Render.com (recomendado)
1. Sube el código a GitHub
2. Crea cuenta en https://render.com
3. New > Web Service > conecta tu repo
4. Build command: `npm install`
5. Start command: `npm start`
6. Agrega las variables de entorno (.env)
7. Plan: Free

### Opción B: Railway.app
1. https://railway.app
2. New Project > Deploy from GitHub
3. Agrega variables de entorno
4. Free tier: 500 hrs/mes

---

## Personalizar la personalidad

Edita `src/personality.js` para cambiar cómo habla Fret.
Puedes ajustar:
- Nivel de nerviosismo
- Expresiones que usa
- Nombre de la IA
- Idioma/acento
