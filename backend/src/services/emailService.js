import nodemailer from 'nodemailer'

/**
 * Envía un correo electrónico.
 * Configura las variables de entorno SMTP_* en .env.
 * En desarrollo, si SMTP_HOST no está definido, imprime el correo en consola.
 *
 * Variables de entorno requeridas:
 *   SMTP_HOST, SMTP_PORT, SMTP_SECURE, SMTP_USER, SMTP_PASS, SMTP_FROM
 */
export async function sendEmail({ to, subject, html, text }) {
  if (!process.env.SMTP_HOST) {
    // Modo simulación: mostrar en consola
    console.info('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    console.info('[EMAIL SIMULADO — configure SMTP_* en .env para enviar real]')
    console.info(`Para    : ${to}`)
    console.info(`Asunto  : ${subject}`)
    console.info(`Mensaje :\n${text}`)
    console.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')
    return { enviado: false, simulado: true }
  }

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT) || 587,
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  })

  await transporter.sendMail({
    from: process.env.SMTP_FROM || '"SIRES" <noreply@ece-global.mx>',
    to,
    subject,
    html,
    text,
  })

  console.info(`[EMAIL] Enviado → ${to} | ${subject}`)
  return { enviado: true }
}
