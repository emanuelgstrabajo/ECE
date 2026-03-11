import { GoogleGenerativeAI } from '@google/generative-ai';
import { SYSTEM_PROMPT } from './personality.js';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Historial de conversación por usuario (en memoria)
const conversations = new Map();
const MAX_HISTORY = 20; // últimos 20 mensajes por usuario

/**
 * Obtiene o crea el historial de un usuario.
 */
function getHistory(userId) {
  if (!conversations.has(userId)) {
    conversations.set(userId, []);
  }
  return conversations.get(userId);
}

/**
 * Genera una respuesta de Fret usando Gemini.
 * @param {string|number} userId - ID del usuario de Telegram
 * @param {string} userMessage - Mensaje del usuario
 * @returns {Promise<string>} Respuesta de Fret
 */
export async function chat(userId, userMessage) {
  const history = getHistory(userId);

  const model = genAI.getGenerativeModel({
    model: 'gemini-2.0-flash',
    systemInstruction: SYSTEM_PROMPT,
  });

  const chatSession = model.startChat({
    history: history.map((msg) => ({
      role: msg.role,
      parts: [{ text: msg.text }],
    })),
  });

  const result = await chatSession.sendMessage(userMessage);
  const response = result.response.text();

  // Guardar en historial
  history.push({ role: 'user', text: userMessage });
  history.push({ role: 'model', text: response });

  // Limitar historial
  while (history.length > MAX_HISTORY) {
    history.shift();
  }

  return response;
}

/**
 * Limpia el historial de un usuario.
 */
export function clearHistory(userId) {
  conversations.delete(userId);
}
