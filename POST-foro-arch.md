# Publicar `dms-es` en el foro de Arch Linux

## Dónde se publica (y en qué idioma)

El foro de Arch es **en inglés** en todas las secciones técnicas. La sección correcta
para compartir una utilidad propia es:

- **Community Contributions** — <https://bbs.archlinux.org/post.php?fid=27>
  ("Share your own created utilities with the Arch community.")

Si lo quieres en español, existe **Other Languages**:
- <https://bbs.archlinux.org/post.php?fid=30> ("Don't speak English well? Post here in your native language.")

**No hagas cross-posting** (el mismo tema en dos secciones): se bloquea y se borra.
Elige **una**.

Reglas que conviene respetar: asunto claro y sin etiquetas tipo `[HELP]`, un tema por
hilo, y usar etiquetas `[code]` para los bloques de consola.

---

## Versión en INGLÉS — para *Community Contributions* (recomendada)

**Subject:**

```
dms-es: Spanish translation package for DankMaterialShell (DMS)
```

**Body:**

```
Hi,

I would like to share dms-es, a small package that brings DankMaterialShell's
Spanish translation from ~59% up to ~90%.

  Repository: https://github.com/pilahito/dms-es
  License:    MIT

Why it is needed
----------------
DMS translates its interface through two separate string sets (the main one
and "DankCommon"), and its Spanish lags behind: the weather panel, the dash
tabs, the settings and the launcher stay in English even when the string is
already translated in the main set. The DankCommon set is missing almost
everything.

What the package does
---------------------
1. Fixes a few entries of the main set (translations/overrides-es.json).
2. Copies the strings that are missing in the DankCommon set from the main
   set, so the components reading it (weather, dash tabs, settings, dock and
   launcher categories) are translated as well. Because it reads them from the
   main set, it works with any DMS version.
3. Adds hand-written translations for strings DMS does not translate yet
   (authentication, battery, bar, island settings).
4. Installs a Hyprland hook that re-applies the patch after every DMS update:
   DMS re-extracts its shell into /run/user/<uid>/danklinux-shell/<hash>/
   on each start, so the patch would otherwise be lost.

Installation (no root needed)
-----------------------------
    git clone https://github.com/pilahito/dms-es.git
    cd dms-es
    ./install.sh              # DMS only
    ./install.sh --todo       # + system locale and language packs (asks for sudo)

Other options: --check (status and coverage), --audit (list of strings still
in English), --revert (restore DMS's original files). It is idempotent, so it
can be run as many times as you want.

Technical notes
---------------
- DMS extracts its shell read-only (directories 555, files 444) but owned by
  the user, so the installer chmods, patches and restores the permissions.
  Root is not required.
- A backup is taken the first time (es.json.bak-dms-es); --revert restores it.
- Tested on Arch Linux with Hyprland 0.56 (Lua config), dms-shell 1.6.1 and
  quickshell 0.3.1. It only touches DMS's translation files, so it should work
  on niri, mango or sway as well.

The long-term goal is to get these translations merged upstream so Spanish
arrives complete for everyone without patches; this repository is a bridge in
the meantime. Feedback and extra strings are welcome.

If you maintain another language: the same trick (copying strings between the
two sets) may be worth doing for fr/de/... until upstream catches up.
```

---

## Versión en ESPAÑOL — para *Other Languages*

**Asunto:**

```
dms-es: traducción al español para DankMaterialShell (DMS)
```

**Cuerpo:**

```
Hola,

Comparto dms-es, un paquete que sube la traducción al español de
DankMaterialShell del ~59 % al ~90 %.

  Repositorio: https://github.com/pilahito/dms-es
  Licencia:    MIT

Por qué hace falta
------------------
DMS traduce su interfaz con dos juegos de cadenas distintos (el principal y
"DankCommon") y su español va por detrás: el panel del clima, las pestañas del
dash, los ajustes y el lanzador se quedan en inglés aunque la cadena ya esté
traducida en el juego principal. En DankCommon falta casi todo.

Qué hace
--------
1. Corrige algunas entradas del juego principal (translations/overrides-es.json).
2. Copia al juego DankCommon las cadenas que le faltan, leyéndolas del
   principal, para que también se traduzcan el clima, las pestañas del dash,
   los ajustes, el dock y las categorías del lanzador.
3. Añade traducciones a mano de cadenas que DMS aún no traduce
   (autenticación, batería, barra, ajustes de la isla).
4. Deja un hook de Hyprland que reaplica el parche tras cada actualización de
   DMS: el shell se vuelve a extraer en /run/user/<uid>/danklinux-shell/<hash>/
   en cada arranque y el parche se perdería.

Instalación (sin root)
----------------------
    git clone https://github.com/pilahito/dms-es.git
    cd dms-es
    ./install.sh              # solo DMS
    ./install.sh --todo       # + locale del sistema y packs de idioma (pide sudo)

Opciones: --check (estado y cobertura), --audit (cadenas que siguen en inglés),
--revert (restaura los ficheros originales de DMS). Es idempotente.

Notas técnicas
--------------
- DMS extrae su shell en solo lectura (directorios 555, ficheros 444) pero
  propiedad del usuario: el instalador se da permiso, parchea y devuelve los
  permisos como estaban. No necesita root.
- La primera vez hace copia de seguridad (es.json.bak-dms-es) y --revert la
  restaura.
- Probado en Arch Linux con Hyprland 0.56 (config en Lua), dms-shell 1.6.1 y
  quickshell 0.3.1. Solo toca los ficheros de traducción de DMS, así que
  debería funcionar igual en niri, mango o sway.

La idea a medio plazo es enviar estas traducciones upstream para que el
español llegue completo a todo el mundo sin parches; este repo es un puente
mientras tanto. Se agradecen sugerencias y más cadenas.
```

---

## Antes de publicar (checklist)

1. **Deja el repo al día**: hay un arreglo sin commitear en `install.sh`
   (enlaza `translations/` al instalar; sin él, el hook no traduce).
2. Revisa el **asunto**: claro y sin `[HELP]`/`[URGENT]`.
3. **Un solo hilo**: Community Contributions *o* Other Languages, no los dos.
4. Enlaza el repositorio en el cuerpo (ya está en la plantilla).
5. Si alguien pide ayuda en el hilo, responde y comparte lo que encuentres.

## Sitios alternativos (más "Arch Way" que el foro)

- **AUR**: empaquetarlo como `dms-es` (PKGBUILD que llame a `install.sh` en
  `package()`). Es la vía natural de Arch para distribuir software.
- **Upstream DMS**: enviar las cadenas como PR a
  <https://github.com/AvengeMedia/DankMaterialShell> — es lo que resuelve el
  problema de raíz.
- **GitHub**: activar *Discussions* o *Releases* en el propio repo.
