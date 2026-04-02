# /agency-build Skill

## Beschreibung
Automatisierter Workflow zum Erstellen von High-End Landingpages für Steuerberater und KMU.

## Verwendung
```
/agency-build <URL der Zielseite>
```

## Workflow-Schritte

### 1. Brand Extraction
- Website der Zielseite scrapen (WebFetch)
- Farben, Fonts, Logo, Design-System extrahieren
- Ergebnis in `brand_guidelines.md` speichern

### 2. Audience Intelligence
- WebSearch nach Branchenspezifischen Kundenproblemen
- Schmerzpunkte, Kundensprache, emotionale Trigger erfassen
- Ergebnis in `audience_insights.md` speichern

### 3. Landingpage Generation
- Tailwind CSS + Vanilla JS (kein Build-Step nötig)
- Hero Section mit Scroll-Animationen (Intersection Observer)
- Trust/Ehrlichkeits-Sektion mit Kundenstimmen
- Services/Dienstleistungen mit Icon-Grid
- Emergency/Notfall-Button (pulsierend, oben rechts + mobile floating)
- ROI-Rechner für Kunden-Überzeugung
- Responsives Design (mobile-first)
- Code in `/build/index.html` ablegen

### 4. Qualitätsprüfung
- Glasmorphism + moderne Ästhetik
- Alle Texte in Kundensprache (aus audience_insights.md)
- Keine generische KI-Sprache
- Performance: Keine externen Frameworks außer Tailwind CDN

## Dateien
```
/brand_guidelines.md    - Extrahierte Markenrichtlinien
/audience_insights.md   - Kundenschmerzpunkte & Sprache
/index.html             - Fertige Landingpage
/AGENCY_BUILD.md        - Diese Dokumentation
```

## Design-Prinzipien
1. **Ehrlichkeit über alles** - "Keine versteckten Kosten" als Kernbotschaft
2. **Kundensprache spiegeln** - Exakte Wörter der Zielgruppe verwenden
3. **Vertrauen visuell kommunizieren** - Grün, Schild-Icons, Trust-Badges
4. **Mobile-first** - Floating Emergency Button auf Mobile
5. **Performance** - Kein Build-Step, sofort deploybar
