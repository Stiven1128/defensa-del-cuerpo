# 🦠 Defensa del Cuerpo — Serious Game

![Godot](https://img.shields.io/badge/Godot-4.x-blue?logo=godot-engine)
![GDScript](https://img.shields.io/badge/GDScript-informational?logo=godot-engine)
![Estado](https://img.shields.io/badge/Estado-En%20desarrollo-yellow)

## 📖 Descripción

**Defensa del Cuerpo** es un *Serious Game* desarrollado en **Godot 4** que simula el sistema inmunológico humano. El jugador controla un **glóbulo blanco (leucocito)** que debe eliminar virus y bacterias antes de que invadan el organismo.

El juego tiene como propósito **educar** sobre cómo funciona el sistema inmune del cuerpo humano de forma interactiva y entretenida.

---

## 🎮 ¿Cómo se juega?

| Control | Acción |
|---------|--------|
| `W A S D` o `↑ ↓ ← →` | Mover el glóbulo blanco |
| `Clic derecho` | Disparar anticuerpos |

---

## 🏗️ Mecánicas del juego

- **3 niveles de dificultad**: Fácil, Medio y Difícil
- **4 oleadas por nivel**: cada oleada aumenta la cantidad de virus
- **Progresión automática**: al completar un nivel pasa al siguiente automáticamente
- **Sistema de vidas**: representado con corazones ❤️
- **Puntuación**: cada virus eliminado suma puntos
- **Spawner dinámico**: los virus aparecen en posiciones aleatorias usando arrays bidimensionales

---

## 💡 ¿Por qué es un Serious Game?

Este juego enseña conceptos reales de biología:

- El **glóbulo blanco** representa los leucocitos del sistema inmune
- Los **virus** representan patógenos que invaden el organismo
- Los **anticuerpos** (balas) representan la respuesta inmune del cuerpo
- Las **oleadas** representan la proliferación viral en el organismo

---

## 🧠 Conceptos técnicos implementados

- ✅ **Arrays unidimensionales**: lista de niveles de dificultad
- ✅ **Arrays bidimensionales**: zonas de spawn de enemigos
- ✅ **Validación y aleatoriedad**: posiciones aleatorias con `randi()`
- ✅ **Shaders**: efectos visuales en el player, virus y fondo
- ✅ **Sistema de señales**: comunicación entre nodos
- ✅ **Autoload (GameData)**: persistencia de datos entre escenas
- ✅ **IA de enemigos**: virus persiguen al jugador dinámicamente

---

## 📁 Estructura del proyecto

```
defensa-del-cuerpo/
├── scenes/
│   ├── Main.tscn          # Escena principal del juego
│   ├── Player.tscn        # Glóbulo blanco (jugador)
│   ├── Virus.tscn         # Enemigo
│   └── Bullet.tscn        # Anticuerpo (proyectil)
├── scripts/
│   ├── GameManager.gd     # Lógica principal del juego
│   ├── Player.gd          # Movimiento y disparo del jugador
│   ├── Virus.gd           # IA del enemigo
│   ├── Spawner.gd         # Generador de virus
│   ├── Bullet.gd          # Proyectil
│   └── GameData.gd        # Autoload: datos globales
├── assets/
│   ├── sprites/           # Imágenes y sprite sheets
│   └── sounds/            # Efectos de sonido y música
└── shader/
    ├── player_glow.gdshader
    ├── virus_shader.gdshader
    └── main.gdshader
```

---

## 👥 Equipo de desarrollo

| Integrante | Rama | Responsabilidad |
|-----------|------|----------------|
| **[Jose Stiven Rodas Beltran]** | `Stiven` | Player, Bullet, GameData, Menú, Shaders |
| **[Mariana Duarte Castro]** | `Mariana` | Virus, Spawner, GameManager |

---

## 🌿 Ramas del repositorio

```bash
main              # Rama principal
Stiven     # Desarrollo del jugador y UI
Mariana    # Desarrollo de enemigos y lógica
```

---

## 🚀 Cómo ejecutar el proyecto

1. Clona el repositorio:
```bash
git clone https://github.com/Stiven1128/defensa-del-cuerpo.git
```
2. Abre **Godot 4**
3. Importa el proyecto desde la carpeta clonada
4. Presiona **F5** para ejecutar

---

## 📚 Tecnologías usadas

- [Godot Engine 4.x](https://godotengine.org/)
- GDScript
- GLSL Shaders

---

*Desarrollado como proyecto académico — Universidad de Caldas*
