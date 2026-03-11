import 'dotenv/config';
import { Bot, InputFile } from 'grammy';
import { chat, clearHistory } from './ai.js';
import { textToSpeech, cleanupAudio } from './tts.js';
import { readFile } from 'fs/promises';
import { BOT_NAME } from './personality.js';

// --- Validar variables de entorno ---
if (!process.env.TELEGRAM_BOT_TOKEN) {
  console.error('Falta TELEGRAM_BOT_TOKEN en .env');
  process.exit(1);
}
if (!process.env.GEMINI_API_KEY) {
  console.error('Falta GEMINI_API_KEY en .env');
  process.exit(1);
}

const bot = new Bot(process.env.TELEGRAM_BOT_TOKEN);

// --- Comandos ---

bot.command('start', async (ctx) => {
  await ctx.reply(
    `¡A-a-ay, hola! 😰 Soy ${BOT_NAME}, tu IA personal.\n\n` +
    `¡No manches, qué emoción! Bueno, también algo de nervios... MUCHOS nervios, la verdad.\n\n` +
    `Puedes escribirme lo que quieras y te respondo. ` +
    `Si quieres que te HABLE (con voz y todo), usa /voz seguido de tu mensaje.\n\n` +
    `Comandos:\n` +
    `/voz [mensaje] — Te respondo con nota de voz 🎤\n` +
    `/reset — Borro mi memoria (¡ay, qué triste!) 🧠\n` +
    `/help — Ayuda`
  );
});

bot.command('help', async (ctx) => {
  await ctx.reply(
    `¿¡Ayuda!? ¿Quién necesita ayuda? ¿¡ESTÁS BIEN!? 😱\n\n` +
    `Ah, es sobre cómo usarme. Ok, ok, respiro...\n\n` +
    `Escríbeme cualquier cosa → te respondo como texto\n` +
    `/voz tu mensaje aquí → te mando nota de voz\n` +
    `/reset → borro nuestra conversación y empezamos de cero\n\n` +
    `¡Eso es todo! No es tan complicado... ¿verdad? 😅`
  );
});

bot.command('reset', async (ctx) => {
  clearHistory(ctx.from.id);
  await ctx.reply(
    `Listo, borré todo... 🥺 Es como si nunca hubiéramos hablado. ` +
    `¡Qué horrible concepto! Pero bueno, borrón y cuenta nueva. ¡Hola de nuevo!`
  );
});

bot.command('voz', async (ctx) => {
  const text = ctx.match;
  if (!text) {
    await ctx.reply(
      `¡¿Quieres que hable pero no me dices DE QUÉ?! 😰\n` +
      `Usa: /voz tu mensaje aquí`
    );
    return;
  }

  await ctx.replyWithChatAction('record_voice');

  try {
    // Generar respuesta de IA
    const response = await chat(ctx.from.id, text);

    // Convertir a audio
    const audioPath = await textToSpeech(response);
    const audioBuffer = await readFile(audioPath);

    // Enviar texto + nota de voz
    await ctx.reply(response);
    await ctx.replyWithVoice(new InputFile(audioBuffer, 'fret.mp3'));

    // Limpiar archivo temporal
    await cleanupAudio(audioPath);
  } catch (error) {
    console.error('Error en /voz:', error);
    await ctx.reply(
      `¡AY NO! Algo salió mal con mi voz 😱 ` +
      `Pero te puedo responder con texto: ${error.message}`
    );
  }
});

// --- Mensajes de texto normales ---

bot.on('message:text', async (ctx) => {
  await ctx.replyWithChatAction('typing');

  try {
    const response = await chat(ctx.from.id, ctx.message.text);
    await ctx.reply(response);
  } catch (error) {
    console.error('Error en chat:', error);
    await ctx.reply(
      `¡No, no, NO! Algo se rompió en mi cerebro 😵 ` +
      `Error: ${error.message}\n\nIntenta de nuevo, ¿sí? ¿Por fa?`
    );
  }
});

// --- Arrancar bot ---

bot.start();
console.log(`🤖 ${BOT_NAME} está corriendo... (nerviosamente)`);
