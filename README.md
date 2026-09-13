# 🇪🇸 Español para DMS — DankMaterialShell

Traducción al español para **[DMS (DankMaterialShell)](https://github.com/AvengeMedia/DankMaterialShell)** en Arch Linux, pensada para
**Hyprland** (también vale para niri, mango, sway… cualquier compositor Wayland con DMS).

DMS traduce su interfaz con dos juegos de traducciones distintos y su español va por detrás:
el panel del clima, las pestañas del dash, los ajustes y el lanzador se quedan en inglés aunque
la traducción exista. Este paquete lo arregla y lo mantiene.

## Cobertura

| | Antes | Con este paquete |
|---|---|---|
| Cadenas de la interfaz en español | ~59 % | **~90 %** |

Las que faltan son ajustes nuevos de DMS (features recientes) que aún no tienen traducción
oficial: puedes verlas con `./install.sh --audit` y enviarlas como PR.

## Instalación

```bash
git clone https://github.com/TU_USUARIO/dms-es.git
cd dms-es
./install.sh              # solo DMS (sin sudo)
```

Con los extras del sistema (pide contraseña de sudo):

```bash
./install.sh --todo       # + locale del sistema + packs de idioma (Firefox, diccionarios, man)
```

Después, si no ves el cambio al momento:

```bash
systemctl --user restart dms
```

## Qué hace exactamente

1. **Retoques del juego principal** (`translations/overrides-es.json`)
   Por ejemplo `up` → `encendido hace` en la tarjeta de usuario.
2. **Copia automática al juego `DankCommon`** (`install.sh`)
   El panel del clima, las pestañas del dash, los ajustes, el dock y las categorías del
   lanzador tiran de un segundo juego de traducciones donde falta casi todo. El instalador
   copia ahí las cadenas que falten **leyéndolas del juego principal**, así que sirve para
   cualquier versión de DMS.
3. **Traducciones extra** (`translations/extras-es.json`)
   Cadenas que DMS no traduce todavía y he traducido a mano (autenticación, batería, barra,
   ajustes de la isla…).
4. **Hook de arranque** (`~/.config/hypr/dms-es/hook.lua` + `require` en `dms/binds-user.lua`)
   DMS extrae su shell en `/run/user/<uid>/danklinux-shell/<hash>/` y **lo vuelve a extraer en
   cada actualización**, así que el parche se perdería: el hook lo reaplica al iniciar sesión.

## Opciones

| Comando | Qué hace |
|---|---|
| `./install.sh` | Traduce DMS (sin sudo) |
| `./install.sh --todo` | + locale del sistema y packs de idioma (sudo) |
| `./install.sh --check` | Estado y cobertura |
| `./install.sh --audit` | Lista las cadenas que siguen en inglés |
| `./install.sh --no-hook` | Aplica sin dejar hook de arranque |
| `./install.sh --revert` | Restaura los ficheros originales de DMS |

Es **idempotente**: puedes ejecutarlo tantas veces como quieras.

## Cómo funciona (detalle técnico)

- DMS extrae su shell a `/run/user/<uid>/danklinux-shell/<hash>/` con permisos de **solo
  lectura** (directorios 555, ficheros 444) pero propiedad del usuario: el instalador se da
  permiso con `chmod`, parchea y devuelve los permisos como estaban. **No necesita root.**
- Se hace copia de seguridad la primera vez (`es.json.bak-dms-es`) y `--revert` la restaura.
- Los componentes que usan el juego `DankCommon` no ven las traducciones del principal: por eso
  hay que copiarlas de un juego a otro (eso hace el paso 2).

## Contribuir

- Añade cadenas a `translations/extras-es.json` (clave = texto original exacto en inglés,
  valor = traducción). El instalador valida que la clave exista realmente.
- Lo ideal es enviar las traducciones **upstream** a DMS para que lleguen a todo el mundo sin
  parches: este repo es un puente mientras su español va por detrás.

## Probado en

- Arch Linux · Hyprland 0.56 (config en Lua) · `dms-shell` 1.6.1 · `quickshell` 0.3.1

## Licencia y créditos

MIT. Las traducciones base son las del propio DMS (`dms-shell`, licencia MIT); este repositorio
solo añade los retoques, la copia entre juegos de traducción y las traducciones que faltan.
