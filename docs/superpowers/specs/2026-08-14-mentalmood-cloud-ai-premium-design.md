# MentalMood — Cloud, AI & Premium Design

**Data:** 2026-08-14
**Stato:** Approvato dall'utente

## Goal

Trasformare MentalMood (app Flutter con database locale drift/SQLite) in un'app con backup cloud **end-to-end criptato**, piani di abbonamento Stripe, feature AI con consenso esplicito e un set di feature premium/retention, mantenendo l'offline-first.

## Architettura

```
Flutter app (drift/SQLite locale = sorgente offline)
      │  HTTPS + JSON (JWT auth)
      ▼
PHP API 8 (api.webdevinnovations.ch/mentalmood/)
      │  PDO prepared statements
      ▼
MySQL (db5021187624.hosting-data.io:3306, utente dbu4475407)
```

- Il SQLite locale resta la fonte di verità per l'uso quotidiano; il server è un archivio di sync.
- I dati arrivano al server **già criptati dall'app** (E2EE): il server e l'amministratore non possono leggerli.
- L'AI (NVIDIA NIM) viene chiamata dalla **PHP API** (proxy) con la chiave API sul server, mai nell'app.

## Crittografia E2EE (envelope encryption)

- **KEK** (Key Encryption Key): derivata dalla password utente con **PBKDF2-HMAC-SHA256, 600.000 iterazioni** (default) + salt casuale (16 byte) per-utente. Mai salvata da nessuna parte.
- **DEK** (Data Encryption Key): chiave AES-256 casuale (32 byte) per utente, generata alla registrazione. Con essa si criptano tutti i dati utente.
- La DEK viene **avvolta** (criptata) con la KEK e salvata sul server come blob → il cambio password ri-avvolge solo la DEK, senza ri-criptare i dati.
- Ogni record: **AES-256-GCM** con nonce casuale a 12 byte (AEAD: rileva manomissioni). Formato serializzato: concatenazione nonce‖ciphertext‖mac, base64.
- `iterations` della PBKDF2 è **iniettabile** (i test usano valori bassi per velocità).
- Librerie: `cryptography` (puro Dart) + `flutter_secure_storage` (DEK sbloccata + token di sessione in Keystore/Keychain).

**Criptati (E2EE):** `name`, `surname`, `birthDate`, `value` (umore), `note`, `tags`, note del diario.
**In chiaro sul server (necessario):** `username`, hash password (Argon2id server-side), `id` record, `updatedAt`, flag `deleted`, DEK avvolta (blob), stato abbonamento.

## Autenticazione

- **JWT doppio token**: access token 15 min + refresh token rotante (ogni uso genera un nuovo refresh, il vecchio viene invalidato → rileva il furto). Firma con segreto forte del server.
- Token conservati in `flutter_secure_storage`, mai in SharedPreferences.
- **Argon2id** (`password_hash` PHP `PASSWORD_ARGON2ID`) per gli hash password lato server.
- **Lockout progressivo**: 5 errori → 1 min, poi 5, 15, 30… (backoff esponenziale).
- **Rate limiting**: `/login` max 5 tentativi/min/IP+utente; `/sync` max 30/min; AI 20 chat/min, 5 analisi/giorno.
- Login a **tempi costanti** (hash fittizio quando l'utente non esiste).
- Revoca totale dei token al cambio password e alla revoca consenso AI.

## Sync offline-first

- Ogni record locale ha `updatedAt` e flag `deleted` (tombstone).
- `POST /sync` riceve batch di upsert+delete dall'app, restituisce i cambi del server più recenti dell'ultimo sync.
- **Integrità payload**: HMAC-SHA256 del body con chiave derivata per-utente + nonce + timestamp (richieste > 5 min o duplicate rifiutate → anti-replay).
- **Gating**: `/sync` richiede abbonamento Standard/Pro o trial attivo → altrimenti **HTTP 402**.
- I dati **non vengono mai cancellati** alla scadenza: restano E2EE e si risbloccano al rinnovo.
- Multi-dispositivo: UX che spiega che i dati viaggiano su tutti i dispositivi.

## Hardening (solo IONOS)

1. **Perimetrale**: nessun Cloudflare per il lancio (aggiungibile in 30 min via DNS).
2. **Trasporto**: HTTPS obbligatorio (redirect 301 in `.htaccess`), TLS 1.2/1.3, HSTS, header `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy`.
3. **Auth**: JWT doppio token, lockout, rate limiting, scoping **dal JWT** (mai da parametri → anti-IDOR).
4. **Integrità**: HMAC + anti-replay (vedi sync).
5. **Applicazione PHP**: PDO 100% (zero concatenazione SQL), whitelist di validazione rigorosa (HTTP 422), `display_errors=off`, log senza PII, versioni nascoste, segreti in `secrets.php` **fuori dalla webroot** (permessi 600), `disable_functions` (`exec`, `shell_exec`, `system`, `eval`, …).
6. **Least privilege MySQL**: utente API solo `SELECT/INSERT/UPDATE/DELETE` sulle tabelle dell'app; utente manutenzione separato.
7. **Monitoraggio**: ban IP automatico dopo soglie (20 fallimenti/10 min), log di sicurezza (timestamp, IP, endpoint, esito — no PII), alert email, backup DB criptati con rotazione e test di ripristino.
8. **Segreti**: rotazione JWT/HMAC al sospetto di compromissione.

**Esclusi (decisione utente):** 2FA (friction), Cloudflare (non necessario al lancio).

## Consenso AI

- I dati restano E2EE di default. Se l'utente **accetta** (schermata informativa: cosa viene analizzato, a cosa serve), l'app invia una **copia decriptata** (solo TLS) con flag `ai_consent: true`.
- **Revoca**: un tocco → il server cancella **fisicamente** le copie AI (`DELETE /ai-data`).
- Richiesto per: insight, consigli, chat, diario CBT guidato.
- Le conversazioni chat **non vengono salvate** sul server (zero log).

## Piani di abbonamento (Stripe, prova 14 giorni su Standard e Pro)

| Piano | Prezzo | Include |
|---|---|---|
| **Free** | €0 | Core (mood, journal, badge, streak, zen, grafici, tags) · Check-in con notifica · PHQ-9/GAD-7 · Risorse emergenza · Export dati |
| **Standard** | ~€3,99/mese | + Backup cloud E2EE · Widget home · Wearable & analisi avanzate (Apple Health/Google Fit/Garmin) |
| **Pro** | ~€9,99/mese | + Tutte le AI (insight, consigli, chat) · Voice journaling · Diario CBT guidato · Report condivisibile · 1 programma CBT incluso |
| **Extra (in-app)** | a consumo | Crediti AI (chat oltre il limite mensile) · Programmi CBT aggiuntivi |

**Flusso:** app → `POST /checkout` → Checkout Session Stripe → pagamento su pagina Stripe → webhook verifica firma → stato in MySQL (`subscriptions`: user_id, stripe_customer_id, stripe_subscription_id, status, plan, trial_ends_at, current_period_end).

**Enforcement server-side:** `/sync` → Standard/Pro; `/ai/*` → Pro; `/checkout` → login richiesto. `POST /webhook/stripe` verifica `Stripe-Signature` (HMAC col webhook secret).

**Tabella `ai_credits`:** saldo per utente, decrementato dal proxy AI, rifornito da acquisti one-time Stripe.

## Feature AI (Pro + consenso; proxy PHP → NVIDIA NIM)

1. **Insight settimanali/mensili**: cron PHP genera analisi dei dati AI-consentiti ("Le tue energie calano il lunedì"), salvate come testo, mostrate in pagina Insight.
2. **Consigli personalizzati**: analisi su richiesta (umore, note, tags) → suggerimenti mirati.
3. **Chat AI**: assistente che conosce lo storico (solo se consenziente), conversazioni non salvate.
4. **Diario CBT guidato**: prompt strutturati (pensiero → distorsione → ristrutturazione) con feedback AI.
5. **Programmi CBT**: percorsi settimanali (lezione + esercizi + check-in); contenuti versionati in DB, progresso sincronizzato. 1 incluso in Pro, altri a pagamento.
6. **Credit AI**: limite mensile di chat in Pro; pacchetti extra acquistabili.

## Compliance

- **Eliminazione account**: un tocco cancella fisicamente dati, copie AI e abbonamento Stripe (cancellazione lato Stripe API).
- **Export dati**: JSON e PDF (portabilità GDPR).
- **Recupero password**: email con token a scadenza da `no-reply@mentalmood.webdevinnovations.ch` (da verificare SPF/DKIM; piano B: casella reale IONOS).

## Retention

- **Check-in giornaliero**: notifica locale + entry rapida.
- **Questionari PHQ-9 / GAD-7**: test clinici standard, alimentano l'AI con dati strutturati.
- **Report mensile condivisibile** col terapeuta (PDF, Pro).
- **Accesso famiglia/terapeuta**: report condiviso con consenso esplicito.

## Premium UI

- **Widget home screen**: mood entry rapida (Standard+).
- **Wearable**: HealthKit/Health Connect, correlazione umore↔sonno/battito/passi; dati aggregati E2EE come le emozioni.
- **Voice journaling**: trascrizione on-device di default (`speech_to_text`) → zero costi e privacy; server riceve solo il testo criptato.

## Infrastruttura

- **API**: PHP 8+, PDO MySQL, su `api.webdevinnovations.ch/mentalmood/` (stesso hosting IONOS), HTTPS con certificato valido.
- **MySQL**: `db5021187624.hosting-data.io:3306`, utente `dbu4475407` (credenziali complete ricevute; password da non esporre nei file di progetto).
- **NVIDIA NIM**: `https://integrate.api.nvidia.com/v1/chat/completions`, modello `meta/llama-3.1-405b-instruct` (valore corrente in `.env` app; parametrizzato). Chiave API nel `secrets.php` del server.
- **Email**: `no-reply@mentalmood.webdevinnovations.ch` (casella inesistente; rischio bounce/spam — piano B casella reale).

## Dati di configurazione forniti dall'utente

| Servizio | Valore | Segreto |
|---|---|---|
| Dominio API | `api.webdevinnovations.ch/mentalmood/` | No |
| MySQL host/port/user | `db5021187624.hosting-data.io:3306` / `dbu4475407` | No |
| MySQL password | (ricevuta) | Sì — solo `secrets.php` sul server |
| NVIDIA API key | (ricevuta in chat; da inserire solo nel server) | Sì — solo `secrets.php` |
| Stripe | account esistente; prodotti/piani da creare con guida | — |
| Email | `no-reply@mentalmood.webdevinnovations.ch` | SMTP password in `secrets.php` |

## Policy di sviluppo (permanenti)

1. **Push sempre**: dopo ogni fase verificata → commit + push (repo `WebDev-Innovations/MentalMood`).
2. **Zero segreti nel repo**: niente chiavi/password in codice o commit; `.env` e `API/` gitignored; verificare i diff prima di ogni commit.
3. **`API/` esclusa da git**: i file PHP vivono in `C:\Flutter\MentalMood\API\` ma la cartella è in `.gitignore` — mai nei commit, mai pushati. Deploy via FTP.

## Fasi di implementazione (TDD)

0. Guide setup (DB MySQL, prodotti Stripe, webhook, NVIDIA, email)
1. Crittografia E2EE (app) — crypto service + key store + test
2. Backend PHP: struttura, DB, auth (register/login, JWT, Argon2id)
3. Sync criptato + gating abbonamento
4. Stripe: checkout, webhook, subscriptions, crediti AI
5. Hardening completo
6. Consenso AI + feature AI (proxy NVIDIA, insight, consigli, chat, diario CBT)
7. Compliance (delete, export, recovery)
8. Retention (check-in, PHQ-9/GAD-7, report)
9. Premium UI (widget, wearable, voice journaling, programmi CBT, accesso famiglia)
10. Verifica end-to-end (dispositivo reale, curl, test mode Stripe, attacchi simulati)

## Limitazioni note

- Email da casella inesistente: possibile bounce/spam → verificare in fase 7, piano B pronto.
- PBKDF2 in puro Dart su Windows/desktop: iterazioni alte → qualche secondo al login; accettabile, ottimizzabile con librerie native in futuro.
- Il recupero password richiede la re-derivazione KEK: flusso "reset" deve far creare una nuova DEK (i dati vecchi restano inaccessibili E2EE) o ri-avvolgere via token temporaneo — decisione in fase 7.
