# Voice-to-Vault — Setup Anleitung

Diese Datei enthält zwei fertige Prompts für Claude Code, mit denen du Voice-to-Vault Schritt für Schritt aufbaust. Einfach in Reihenfolge ausführen.

---

## Was Voice-to-Vault macht

Du sprichst kurz in dein Handy → Audio wird transkribiert (Whisper) → Claude strukturiert den Text in saubere Markdown-Notes → Notes landen automatisch in deinem OneDrive Vault (CK Second Brain).

**Kreis schließt sich:** Genau die OneDrive-Schreib-Einschränkung der ms365-MCP-Verbindung wird damit gelöst — deine eigene App schreibt, was die MCP nicht darf.

---

## Phase 1 — Azure Setup (Microsoft Graph API Zugang)

Damit die App in deinen OneDrive schreiben darf, brauchst du eine App-Registration in Azure. Du musst nichts wissen — Claude Code führt dich Klick für Klick durch.

### Prompt 1 — kopieren und in Claude Code einfügen

```
Ich möchte eine Azure App-Registration für meinen persönlichen Microsoft 365 Account
(kovac@christian-kovac.at) anlegen, damit eine Web-App Dateien in meinen OneDrive
schreiben kann (Microsoft Graph API).

Führe mich Schritt für Schritt durch portal.azure.com:

1. Wo genau ich klicken muss (Menüpunkt, Button-Name, Reihenfolge)
2. Welche Werte ich in jedes Feld eintragen muss
3. Welche API Permissions ich brauche (Files.ReadWrite, offline_access, User.Read)
4. Wie ich ein Client Secret erstelle und sicher speichere
5. Wie ich die drei Werte rausziehe die ich später brauche:
   - Application (client) ID
   - Directory (tenant) ID  
   - Client Secret Value

Für Redirect URI: http://localhost:3000/auth/callback und später eine Netlify URL.

Erkläre jeden Schritt so, als hätte ich noch nie Azure gesehen.
Frage mich nach jedem Schritt, ob es funktioniert hat, bevor du weitermachst.
```

### Was du am Ende von Phase 1 hast

Drei Werte, die du sicher aufschreibst (NICHT in den Repo committen):

- `AZURE_CLIENT_ID` = ...
- `AZURE_TENANT_ID` = ...
- `AZURE_CLIENT_SECRET` = ...

---

## Phase 2 — App bauen (Netlify Functions + Claude API + Whisper)

Sobald Phase 1 fertig ist, diesen Prompt einfügen. Claude Code baut den kompletten Code.

### Prompt 2 — kopieren und in Claude Code einfügen

```
Baue Voice-to-Vault als Erweiterung im bestehenden Repo (Steuerberater-Support_1).
Das Repo nutzt bereits Netlify Functions — bitte dem gleichen Pattern folgen wie
netlify/functions/analyze.js.

Architektur:

1. Frontend: voice-to-vault.html
   - Großer Record-Button (MediaRecorder API, Browser-Mikrofon)
   - Status-Anzeige (recording / transcribing / structuring / saving / done)
   - Vorschau der erzeugten Markdown-Notiz vor dem Speichern
   - "In Vault speichern" Button

2. Netlify Function: netlify/functions/transcribe.js
   - Empfängt Audio-Blob (base64)
   - Schickt an OpenAI Whisper API (Model: whisper-1)
   - Gibt Transkript zurück

3. Netlify Function: netlify/functions/structure.js
   - Empfängt Roh-Transkript
   - Schickt an Claude API (claude-sonnet-4-6) mit Prompt-Caching
   - System-Prompt: "Du strukturierst gesprochene Gedanken in saubere Obsidian-
     Markdown-Notizen. Output-Format: YAML Frontmatter (title, date, tags, type),
     dann strukturierter Body mit Headings, Bullet Points, Aufgaben als [ ]."
   - Tags automatisch aus Inhalt ableiten

4. Netlify Function: netlify/functions/save-to-vault.js
   - Empfängt strukturiertes Markdown + Titel
   - Authentifiziert via Microsoft Graph (Client Credentials Flow oder OAuth)
   - Schreibt Datei nach: /CK Second Brain/00_Inbox/{YYYY-MM-DD}-{slug}.md
   - Gibt Erfolg + OneDrive-Link zurück

Environment Variables (in Netlify Dashboard setzen, NICHT im Code):
- OPENAI_API_KEY
- ANTHROPIC_API_KEY (gibt es schon im analyze.js Pattern)
- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- AZURE_CLIENT_SECRET
- ONEDRIVE_USER_ID (kovac@christian-kovac.at)

Wichtig:
- Keine API Keys ins Frontend
- Fehler vom User abfangen und freundlich anzeigen (auf Deutsch)
- Den bestehenden TaxAutoAustria Look übernehmen (Tailwind, grüne Accent-Farbe)
- Voice-to-Vault als neuen Navigationspunkt in index.html ergänzen
```

---

## Phase 3 — Deployment & Test

Nach dem Build:

1. **Environment Variables** in Netlify Dashboard setzen:
   - `Site Settings → Environment variables`
   - Alle 6 Variables aus Phase 2 eintragen
2. **Deploy** triggern (push auf main oder manuell)
3. **Test** auf der live URL:
   - Mikrofon-Permission erlauben
   - 10 Sekunden was sprechen
   - Schauen ob die `.md` Datei in OneDrive `/CK Second Brain/00_Inbox/` landet

---

## Troubleshooting

**Mikrofon geht nicht:** Browser braucht HTTPS (Netlify hat das automatisch) oder `localhost`.

**Graph API 401:** Client Secret abgelaufen? Permissions richtig admin-consented?

**Whisper Fehler:** Audio zu lang (max 25 MB) oder falsches Format. App sollte als webm/opus aufnehmen.

**Claude Output kein valides Markdown:** System-Prompt nachschärfen, Beispiel-Output ins System-Prompt einbauen (Prompt-Caching nutzt das eh kostenlos).

---

## Wichtige Hinweise

- **API Keys NIEMALS in den Repo committen.** Nur in Netlify Environment Variables.
- **`.env` Datei** in `.gitignore` lassen (ist sie schon).
- **Client Secret** läuft nach 6/12/24 Monaten ab — Erinnerung im Kalender setzen.
- **Whisper Kosten:** ~$0.006 pro Minute Audio. 100 kurze Notizen/Monat ≈ $1.
- **Claude Kosten:** Mit Prompt-Caching ~$0.50–$2/Monat für deinen Use-Case.

---

## Status-Checkliste

- [ ] Phase 1: Azure App-Registration angelegt
- [ ] Phase 1: Drei Keys sicher gespeichert (Password Manager)
- [ ] Phase 2: Code generiert und lokal getestet
- [ ] Phase 2: Environment Variables in Netlify gesetzt
- [ ] Phase 3: Live deploy funktioniert
- [ ] Phase 3: Erster echter Voice-Note landet im Vault

Sobald alle Boxen abgehakt sind: Voice-to-Vault läuft.
