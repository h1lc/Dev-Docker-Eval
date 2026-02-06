import express from "express";
import pg from "pg";
import fs from "fs";

const { Pool } = pg;

const app = express();
const port = process.env.PORT || 3000;

// Lire le mot de passe depuis le fichier secret si disponible
function readSecret(filePath) {
  try {
    if (filePath && fs.existsSync(filePath)) {
      return fs.readFileSync(filePath, 'utf8').trim();
    }
  } catch (e) {
    console.warn(`Could not read secret file ${filePath}:`, e.message);
  }
  return null;
}

// Construire DATABASE_URL depuis les variables d'environnement et secrets
function buildDatabaseUrl() {
  // Si DATABASE_URL est déjà défini, l'utiliser (rétrocompatibilité)
  if (process.env.DATABASE_URL) {
    return process.env.DATABASE_URL;
  }

  // Lire les secrets depuis les fichiers _FILE ou variables d'environnement
  const userFile = process.env.POSTGRES_USER_FILE;
  const user = userFile ? readSecret(userFile) : (process.env.POSTGRES_USER || 'postgres');
  
  const dbFile = process.env.POSTGRES_DB_FILE;
  const db = dbFile ? readSecret(dbFile) : (process.env.POSTGRES_DB || 'postgres');
  
  const passwordFile = process.env.POSTGRES_PASSWORD_FILE;
  const password = passwordFile ? readSecret(passwordFile) : (process.env.POSTGRES_PASSWORD || '');
  
  const host = process.env.POSTGRES_HOST || 'db';
  const port = process.env.POSTGRES_PORT || '5432';

  return `postgres://${user}:${password}@${host}:${port}/${db}`;
}

const databaseUrl = buildDatabaseUrl();

// Connexion DB
const pool = new Pool({
  connectionString: databaseUrl
});

app.get("/api/health", async (req, res) => {
  try {
    const r = await pool.query("SELECT 1 as ok");
    res.json({ status: "ok", db: r.rows[0].ok });
  } catch (e) {
    res.status(500).json({ status: "error", error: e.message });
  }
});

app.get("/api/message", async (req, res) => {
  res.json({ message: "Hello from API" });
});

app.listen(port, () => {
  console.log(`API listening on port ${port}`);
  const safeUrl = databaseUrl.replace(/:([^:@]+)@/, ':****@');
  console.log(`DATABASE_URL=${safeUrl}`);
});
