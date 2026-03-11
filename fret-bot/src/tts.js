import { MsEdgeTTS, OUTPUT_FORMAT } from 'msedge-tts';
import { writeFile, unlink } from 'fs/promises';
import { randomUUID } from 'crypto';
import { tmpdir } from 'os';
import { join } from 'path';

const VOICE = process.env.TTS_VOICE || 'es-MX-DaliaNeural';

/**
 * Convierte texto a un archivo de audio .mp3 usando Edge TTS.
 * @param {string} text - Texto a convertir
 * @returns {Promise<string>} Ruta del archivo temporal de audio
 */
export async function textToSpeech(text) {
  const tts = new MsEdgeTTS();
  await tts.setMetadata(VOICE, OUTPUT_FORMAT.AUDIO_24KHZ_96KBITRATE_MONO_MP3);

  const tempPath = join(tmpdir(), `fret-${randomUUID()}.mp3`);
  const readable = tts.toStream(text);

  const chunks = [];
  for await (const chunk of readable) {
    if (Buffer.isBuffer(chunk)) {
      chunks.push(chunk);
    }
  }

  await writeFile(tempPath, Buffer.concat(chunks));
  return tempPath;
}

/**
 * Elimina un archivo temporal de audio.
 */
export async function cleanupAudio(filePath) {
  try {
    await unlink(filePath);
  } catch {
    // ignorar si ya no existe
  }
}
