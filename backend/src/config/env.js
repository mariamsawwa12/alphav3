const dotenv = require('dotenv');
const path = require('path');

const envFile = process.env.NODE_ENV === 'test' ? '.env.test' : '.env';
dotenv.config({ path: path.resolve(process.cwd(), envFile) });

function requiredEnv(name) {
  const value = process.env[name];

  if (!value || value.trim() === '') {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value.trim();
}

function numberEnv(name, defaultValue) {
  const value = process.env[name];

  if (!value) {
    return defaultValue;
  }

  const parsedValue = Number(value);

  if (!Number.isFinite(parsedValue)) {
    throw new Error(`Environment variable ${name} must be a valid number`);
  }

  return parsedValue;
}

const env = {
  nodeEnv: process.env.NODE_ENV ?? 'development',
  port: numberEnv('PORT', 3000),
  apiPrefix: process.env.API_PREFIX ?? '/api/v1',

  dbHost: requiredEnv('DB_HOST'),
  dbPort: numberEnv('DB_PORT', 3306),
  dbUser: requiredEnv('DB_USER'),
  dbPass: requiredEnv('DB_PASSWORD'),
  dbName: requiredEnv('DB_NAME'),
  dbConnectionLimit: numberEnv('DB_CONNECTION_LIMIT', 10),

  bcryptSaltRounds: numberEnv('BCRYPT_SALT_ROUNDS', 10),

  jwtAccessSecret: requiredEnv('JWT_ACCESS_SECRET'),
  jwtRefreshSecret: requiredEnv('JWT_REFRESH_SECRET'),
  jwtAccessExpiresIn: process.env.JWT_ACCESS_EXPIRES_IN ?? '15m',
  jwtRefreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN ?? '30d',

  n8nOtpWebhookUrl: process.env.N8N_OTP_WEBHOOK_URL,
};

module.exports = { env };
