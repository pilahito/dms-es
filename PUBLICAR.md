# Cómo publicar este repositorio en GitHub

El repo ya está listo y commiteado en `~/Proyectos/dms-es`. Solo falta subirlo a tu cuenta.
Elige **una** de las tres vías.

---

## Vía 1 — Desde la web + una terminal (la más rápida)

1. Entra en <https://github.com/new>
   - **Repository name:** `dms-es`
   - **Public** (para que cualquiera lo use)
   - **No** marques "Add a README" (ya lo tienes)
2. Crea un token: <https://github.com/settings/tokens> → *Generate new token (classic)* →
   marca el permiso **`repo`** → genera y copia el token.
3. En una terminal:

```bash
cd ~/Proyectos/dms-es
git remote add origin https://github.com/TU_USUARIO/dms-es.git
git push -u origin main
# Usuario: tu usuario de GitHub
# Contraseña: PEGA EL TOKEN (no tu contraseña normal)
```

---

## Vía 2 — Con `gh` (GitHub CLI), autenticando en el navegador

```bash
# instalar (pide contraseña de sudo)
~/Escritorio/permisos-gui.sh pacman -S --needed github-cli

# autenticar (abre el navegador; hay que ejecutarlo en TU terminal)
gh auth login          # GitHub.com → HTTPS → Login with a web browser

# crear el repo y subirlo de una vez
cd ~/Proyectos/dms-es
gh repo create dms-es --public --source=. --remote=origin --push
```

---

## Vía 3 — Clave SSH (si prefieres no usar tokens)

```bash
ssh-keygen -t ed25519 -C "tu@correo"
cat ~/.ssh/id_ed25519.pub      # pégala en https://github.com/settings/keys

# crea el repo vacío en https://github.com/new  y luego:
cd ~/Proyectos/dms-es
git remote add origin git@github.com:TU_USUARIO/dms-es.git
git push -u origin main
```

---

## Después de publicar

- Cambia en `README.md` la línea del `git clone` para que apunte a tu repo
  (donde pone `TU_USUARIO`).
- Cada vez que quieras actualizar:

```bash
cd ~/Proyectos/dms-es
git add -A && git commit -m "más traducciones" && git push
```

- **Ideal a medio plazo**: enviar estas traducciones *upstream* a DMS para que su español
  llegue completo a todo el mundo sin parches. Este repo es un puente mientras tanto.
