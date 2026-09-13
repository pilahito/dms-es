#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  ESPAÑOL PARA DMS — instalador
#  DankMaterialShell (DMS) en español, para Arch + Hyprland (o niri/mango)
#
#  Qué hace:
#    1. Aplica los retoques de traducción al juego principal de DMS
#    2. Copia al juego "DankCommon" las cadenas que falten (el panel del
#       clima, las pestañas del dash, los ajustes y el lanzador usan ese)
#    3. Añade traducciones extra para lo que DMS deja en inglés
#    4. Deja un hook para reaplicarlo tras cada inicio o actualización de DMS
#
#  Uso:
#    ./install.sh                # traduce DMS (sin sudo)
#    ./install.sh --os           # + locale del sistema en español (sudo)
#    ./install.sh --paquetes     # + packs de idioma (Firefox, diccionarios…)(sudo)
#    ./install.sh --todo         # todo lo anterior
#    ./install.sh --check        # estado y cobertura
#    ./install.sh --audit        # lista lo que sigue sin traducir
#    ./install.sh --revert       # deja las traducciones originales de DMS
#
#  Requisitos: dms-shell instalado y DMS en ejecución (extrae su shell en
#  /run/user/<uid>/danklinux-shell/<hash>/), python3 y jq.
# ═══════════════════════════════════════════════════════════════
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TR="$DIR/translations"
BINDS_USER="$HOME/.config/hypr/dms/binds-user.lua"
HOOK_DIR="$HOME/.config/hypr/dms-es"
HOOK_LUA="$HOOK_DIR/hook.lua"
SELF_DEST="$HOME/.config/cyberpunk/dms-es.sh"
REQUIRE_LINE='require("dms-es.hook")'

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "   ${GREEN}✓${NC} $*"; }
info() { echo -e "   ${CYAN}ℹ${NC} $*"; }
warn() { echo -e "   ${YELLOW}⚠${NC} $*"; }
err()  { echo -e "   ${RED}✗${NC} $*"; }
step() { echo -e "${YELLOW}[$1]${NC} $2"; }

DO_OS=0; DO_PKGS=0; DO_HOOK=1; MODE="apply"
for arg in "$@"; do
  case "$arg" in
    --os)        DO_OS=1 ;;
    --paquetes)  DO_PKGS=1 ;;
    --todo)      DO_OS=1; DO_PKGS=1 ;;
    --no-hook)   DO_HOOK=0 ;;
    --check)     MODE="check" ;;
    --audit)     MODE="audit" ;;
    --revert)    MODE="revert" ;;
    -h|--help)   sed -n '2,25p' "$0"; exit 0 ;;
    *) echo "Opción desconocida: $arg" >&2; exit 2 ;;
  esac
done

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════╗"
echo "║   🇪🇸  ESPAÑOL PARA DMS — DankMaterialShell     ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

for c in python3 jq; do command -v "$c" >/dev/null 2>&1 || { err "Falta $c"; exit 1; }; done

shell_dir() { ls -d /run/user/"$(id -u)"/danklinux-shell/*/ 2>/dev/null | sort | tail -1; }
D="$(shell_dir)"
if [ -z "$D" ]; then
  err "DMS no ha extraído su shell. Arranca DMS y vuelve a intentarlo:"
  echo -e "     ${CYAN}systemctl --user start dms${NC}"
  exit 1
fi
MAIN="$D/translations/poexports/es.json"
DC="$D/DankCommon/translations/poexports/es.json"
[ -f "$MAIN" ] || { err "No encuentro $MAIN (¿versión de DMS distinta?)"; exit 1; }

cobertura() {
  python3 - "$D" << 'PY'
import json, re, sys, glob, os
D = sys.argv[1]
sets = []
for p in (D + 'DankCommon/translations/poexports/es.json', D + 'translations/poexports/es.json'):
    if os.path.exists(p):
        try: sets.append(json.load(open(p, encoding='utf-8')))
        except Exception: pass
def tr(t):
    for d in sets:
        for obj in d.values():
            if isinstance(obj, dict) and obj.get(t): return obj[t]
    return None
terms = set()
for f in glob.glob(D + '**/*.qml', recursive=True):
    try: terms.update(re.findall(r'I18n\.tr\("([^"]+)"', open(f, encoding='utf-8').read()))
    except Exception: pass
faltan = sorted(t for t in terms if not tr(t))
print(f"COBERTURA {len(terms)-len(faltan)}/{len(terms)} ({100*(len(terms)-len(faltan))//max(len(terms),1)}%)")
for t in faltan: print(t)
PY
}

case "$MODE" in
  check)
    echo -e "${YELLOW}Estado:${NC}"
    printf "   %-24s %s\n" "shell extraído" "$D"
    printf "   %-24s %s\n" "juego principal" "$([ -f "$MAIN.bak-dms-es" ] && echo 'traducido (con backup)' || echo 'original')"
    printf "   %-24s %s\n" "juego DankCommon" "$([ -f "$DC.bak-dms-es" ] && echo 'traducido (con backup)' || echo 'original')"
    printf "   %-24s %s\n" "hook de arranque" "$([ -f "$HOOK_LUA" ] && echo sí || echo no)"
    printf "   %-24s %s\n" "require en binds" "$(grep -cF "$REQUIRE_LINE" "$BINDS_USER" 2>/dev/null)"
    echo; cobertura | head -1 | sed 's/^/   /'
    ;;
  audit)
    info "Cadenas que aún salen en inglés (para contribuir):"
    cobertura | tail -n +2 | head -60 | sed 's/^/     · /'
    ;;
  revert)
    chmod -R u+w "$D" 2>/dev/null
    for f in "$MAIN" "$DC"; do
      [ -f "$f.bak-dms-es" ] && cp -f "$f.bak-dms-es" "$f" && ok "restaurado $(basename "$(dirname "$(dirname "$f")")")/es.json"
    done
    chmod -R a-w "$D" 2>/dev/null
    rm -f "$HOOK_LUA"; rmdir "$HOOK_DIR" 2>/dev/null
    [ -f "$BINDS_USER" ] && { grep -vF "$REQUIRE_LINE" "$BINDS_USER" > "$BINDS_USER.tmp" && mv "$BINDS_USER.tmp" "$BINDS_USER"; }
    ok "hook quitado · reinicia DMS para verlo: systemctl --user restart dms"
    ;;
  apply)
    step "1/3" "Aplicando traducciones a DMS…"
    chmod -R u+w "$D" 2>/dev/null
    python3 - "$D" "$TR" << 'PY'
import json, re, sys, glob, os
D, TR = sys.argv[1], sys.argv[2]
main_p = D + 'translations/poexports/es.json'
dc_p   = D + 'DankCommon/translations/poexports/es.json'
main = json.load(open(main_p, encoding='utf-8'))
dc   = json.load(open(dc_p, encoding='utf-8')) if os.path.exists(dc_p) else {}

def backup(p):
    if not os.path.exists(p + '.bak-dms-es'):
        import shutil; shutil.copy2(p, p + '.bak-dms-es')

def dump(p, d):
    json.dump(d, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=4)

# overrides del usuario (paquete)
ov  = json.load(open(TR + '/overrides-es.json', encoding='utf-8'))
dcv = json.load(open(TR + '/overrides-dankcommon.json', encoding='utf-8'))
ex  = json.load(open(TR + '/extras-es.json', encoding='utf-8'))

# 1) juego principal: overrides + extras en un contexto propio
backup(main_p)
main.setdefault('_es_pack', {}).update(ov)
main.setdefault('_es_pack', {}).update({k: v for k, v in ex.items()})
dump(main_p, main)

# 2) DankCommon: overrides + extras + copia automática de lo que falte
if os.path.exists(dc_p):
    backup(dc_p)
    for k, v in {**dcv, **ex}.items():
        dc[k] = {k: v}
    def find(term):
        for obj in main.values():
            if isinstance(obj, dict) and obj.get(term): return obj[term]
        return None
    terms = set()
    for pat in ('Modules/Weather*', 'Modules/DankDash*', 'Widgets*', 'Modules/ControlCenter*',
                'Modules/Settings*', 'Modules/Launcher*', 'Modules/Dock*', 'Modules/Bar*'):
        for f in glob.glob(D + pat + '/**/*.qml', recursive=True):
            try: terms.update(re.findall(r'I18n\.tr\("([^"]+)"', open(f, encoding='utf-8').read()))
            except Exception: pass
    nuevas = 0
    for t in terms:
        if isinstance(dc.get(t), dict) and dc[t].get(t): continue
        v = find(t)
        if v: dc[t] = {t: v}; nuevas += 1
    dump(dc_p, dc)
    print(f"   ✓ juego principal y DankCommon actualizados ({len(dc)} entradas en DankCommon, {nuevas} nuevas)")
else:
    print("   · esta versión de DMS no tiene juego DankCommon (nada que copiar)")
PY
    chmod -R a-w "$D" 2>/dev/null
    ok "permisos devueltos a solo lectura"

    if [ "$DO_HOOK" = 1 ]; then
      step "2/3" "Hook de arranque (para que aguante actualizaciones)…"
      mkdir -p "$HOOK_DIR" "$(dirname "$SELF_DEST")"
      cp -f "$0" "$SELF_DEST"; chmod +x "$SELF_DEST"
      cat > "$HOOK_LUA" << EOF
-- Reaplica el paquete de español de DMS tras cada inicio de sesión
-- (DMS extrae su shell en /run y una actualización lo reemplaza).
hl.on("hyprland.start", function()
	hl.exec_cmd("sleep 20; $SELF_DEST apply --no-hook >/dev/null 2>&1")
end)
EOF
      ok "hook: $HOOK_LUA"
      if [ -f "$BINDS_USER" ] && ! grep -qF "$REQUIRE_LINE" "$BINDS_USER"; then
        cp -f "$BINDS_USER" "$BINDS_USER.bak.$(date +%Y%m%d-%H%M%S)"
        printf '\n-- Español de DMS\n%s\n' "$REQUIRE_LINE" >> "$BINDS_USER"
        ok "require añadido a binds-user.lua"
      fi
    else
      step "2/3" "Hook omitido (--no-hook)"
    fi
    ;;
esac

# ── extras del sistema (opcionales, con sudo) ─────────────────
if [ "$DO_OS" = 1 ] || [ "$DO_PKGS" = 1 ]; then
  step "3/3" "Ajustes del sistema…"
fi
if [ "$DO_OS" = 1 ]; then
  if grep -q '^LANG=es_ES.UTF-8' /etc/locale.conf 2>/dev/null; then
    ok "el sistema ya está en es_ES.UTF-8"
  else
    info "Configurando locale del sistema (pedirá contraseña)…"
    sudo sed -i 's/^#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen 2>/dev/null
    sudo locale-gen && printf 'LANG=es_ES.UTF-8\nLANGUAGE=es_ES:es\n' | sudo tee /etc/locale.conf >/dev/null \
      && ok "locale del sistema: es_ES.UTF-8"
  fi
fi
if [ "$DO_PKGS" = 1 ]; then
  PKGS=(firefox-i18n-es-es hunspell-es_es hyphen-es mythes-es man-pages-es)
  FALTAN=(); for p in "${PKGS[@]}"; do pacman -Qq "$p" >/dev/null 2>&1 || FALTAN+=("$p"); done
  if [ "${#FALTAN[@]}" -eq 0 ]; then ok "packs de idioma ya instalados"
  else sudo pacman -S --needed --noconfirm "${FALTAN[@]}" && ok "packs instalados"; fi
fi

if [ "$MODE" = "apply" ]; then
  echo
  echo -e "${GREEN}╔═══════════════════════════════════════════════╗"
  echo -e "║        ✅ DMS EN ESPAÑOL APLICADO              ║"
  echo -e "╚═══════════════════════════════════════════════╝${NC}"
  cobertura | head -1 | sed 's/^/  📊 /'
  echo -e "  ℹ️  Si no ves el cambio: ${CYAN}systemctl --user restart dms${NC}"
  echo -e "  ↩️  Para revertir: ${CYAN}$0 --revert${NC}"
  echo
fi
