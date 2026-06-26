# Street_Fighter

## 🎮 Controles

| Acción | Player 1 | Player 2 |
|--------|----------|----------|
| Izquierda | A | ← |
| Derecha | D | → |
| Saltar | W | ↑ |
| Golpe ligero | F | J |
| Golpe pesado | G | K |
| Bloquear | S | ↓ |

> **⚠️ Nota:** Al probar el juego ahora, los personajes se verán **invisibles** en la arena porque los SpriteFrames aún están vacíos. Una vez que se agreguen los frames a cada `*_spriteframes.tres`, los personajes aparecerán con sus sprites y animaciones.

---

## 🎨 Guía para agregar animaciones a los personajes

### Requisitos
- Tener Godot 4.6 instalado
- Tener los spritesheets de los personajes (ya están importados en `assets/characters/`)

### Archivos de animación (SpriteFrames)
Cada personaje tiene un archivo `.tres` en `assets/characters/` que debes abrir y rellenar.
**Mientras estén vacíos, el personaje no se verá en la arena. Al rellenarlos aparecerá automáticamente.**
- `DeeJay_spriteframes.tres`
- `Cammi_spriteframes.tres`
- `MBison_spriteframes.tres`

### Pasos para cada personaje

1. **Abre el proyecto en Godot 4.6**

2. **Selecciona el archivo `.tres` del personaje** en el panel FileSystem (ej: `assets/characters/DeeJay_spriteframes.tres`)

3. **En el Inspector**, haz clic en "SpriteFrames" y luego en el botón "Array [x]" o "Open" para abrir el editor de SpriteFrames

4. **Agrega las siguientes animaciones** (nombres exactos, sin errores):
   ```
   quieto
   caminar
   saltar
   caer
   golpe_ligero
   golpe_pesado
   bloquear
   recibir_daño
   nocaut
   ```

5. **Para cada animación:**
   - Selecciona la animación en la lista superior del editor de SpriteFrames
   - Arrastra los frames del spritesheet (PNG) desde el FileSystem a la línea de tiempo
   - Ajusta la velocidad (FPS) según el movimiento:
     - `quieto`: 4-6 FPS (respiración)
     - `caminar`: 8-10 FPS
     - `saltar` / `caer`: 6-8 FPS
     - `golpe_ligero`: 12-15 FPS (rápido)
     - `golpe_pesado`: 8-10 FPS
     - `bloquear`: 4-6 FPS
     - `recibir_daño`: 8-10 FPS
     - `nocaut`: 4-6 FPS
   - **Loop**: marca esta opción para animaciones que se repiten (`quieto`, `caminar`). Desmárcala para las que no (`golpe_ligero`, `golpe_pesado`, `saltar`, `caer`, `bloquear`, `recibir_daño`, `nocaut`)

6. **Guarda** el archivo (Ctrl+S)

### Mapeo de animaciones por personaje
Cada personaje usa su propio spritesheet. Los archivos ya están importados en el proyecto:

| Personaje | Spritesheet |
|-----------|-------------|
| DeeJay | `Arcade - Street Fighter 2 _ Super Street Fighter 2 - Fighters - Dee Jay.png` |
| Cammi | `Arcade - Street Fighter 2 _ Super Street Fighter 2 - Fighters - Cammy.png` |
| M.Bison | `Arcade - Street Fighter 2 _ Super Street Fighter 2 - Fighters - M. Bison.png` |

### Probar en el juego
1. Ejecuta el proyecto (F5)
2. Selecciona el personaje
3. Al entrar en combate, el personaje mostrará los sprites que hayas asignado. Si los SpriteFrames están vacíos, no se verá nada (es normal hasta que se agreguen los frames).

### Notas importantes
- Los nombres de las animaciones deben coincidir **exactamente** (incluyendo mayúsculas/minúsculas y guiones bajos)
- Si una animación falta, el juego mostrará un error en la consola
- Todas las animaciones deben existir, aunque sea con un solo frame
- Cada personaje tiene su propio archivo `.tres` independiente
