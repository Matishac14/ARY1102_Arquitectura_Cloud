# Plantilla Maestra y Catálogo de Diapositivas DUOC UC 2026

Motor corporativo de diapositivas en HTML5/CSS3 con fidelidad 100% a la identidad institucional **"Verdaderamente Conectad@s 2026"** de DUOC UC (`10_GOV_AST_2026_PLANTILLA_COLOR_PRESENTACIONES_DUOC.pptx`).

---

## 📁 Contenido Completo del Paquete

Esta carpeta contiene **todos los recursos oficiales y los 16 tipos de diapositivas estandarizados**, limpios de cualquier contenido o logotipo ajeno a DUOC UC:

```text
duoc-template/
├── index.html                   # Presentación maestra con los 16 tipos de diapositivas activos
├── templates/
│   └── slide-types.html         # Catálogo de layouts para copiar y pegar bloques individuales
├── css/
│   └── duoc-theme.css           # Sistema de estilos 16:9, paleta oficial y reglas anti-desborde
├── js/
│   └── presenter.js             # Motor interactivo (navegación, pantalla completa, PDF)
└── assets/
    └── brand/                   # RECURSOS VISUALES CORPORATIVOS OFICIALES
        ├── duoc-logo.png             # Logotipo oficial DUOC UC azul marino
        ├── duoc-black-strip.svg      # Tira vertical negra decorativa oficial
        ├── cover-photo.png           # Fotografía corporativa de portada
        ├── cover-slogan.png          # Gráfica del slogan de portada
        ├── closing-slogan.png        # Gráfica oficial de acreditación CNA 7 años (cierre)
        ├── accent-bar.png            # Barra de acento
        ├── agenda-mosaic-1..3.png    # Tríptico fotográfico para la agenda
        ├── section-bg-1..4.png       # Fondos ilustrativos de sección
        ├── content-side-1..3.png     # Fondos para diapositivas split
        ├── placeholder-diagram.svg   # Diagrama de arquitectura vectorial neutral
        ├── placeholder-mockup.svg    # Captura de interfaz/pantalla institucional neutral
        └── placeholder-logo.svg      # Isotipo vectorial neutral para partners
```

---

## 📋 Catálogo de los 16 Tipos de Diapositiva Incluidos

| Tipo | Nombre del Layout | Elementos Visuales Principales |
|:---:|:---|:---|
| **01** | **Portada Principal** | Foto institucional izquierda, tarjeta con cuadrado amarillo `#FFB71B` y slogan `#VerdaderamenteConectad@s`. |
| **02** | **Agenda / Índice** | Tríptico de fotos a la izquierda, 6 badges circulares numerados sobre fondo `#E6E7E8`. |
| **03** | **Separador de Sección** | Tarjeta de título `#E6E7E8` a la izquierda, arte ilustrativo a la derecha. |
| **04** | **Separador Invertido** | Arte ilustrativo a la izquierda, tarjeta de título `#E6E7E8` a la derecha. |
| **05** | **Split con Foto Lateral** | Fotografía con bordes redondeados (37%) + 2 tarjetas `#E6E7E8` de viñetas (63%). |
| **06** | **3 Columnas con Tira Negra** | Tira negra lateral `duoc-black-strip.svg` + 3 tarjetas verticales `.card-duoc-col`. |
| **07** | **4 Features con Iconos** | Grilla 2×2 con iconos circulares amarillos y descripciones operativas. |
| **08** | **Comparativa 2 Columnas** | Dos tarjetas anchas lado a lado (ej. Modelo Anterior vs. Modelo Actual). |
| **09** | **Panel de Métricas / KPIs** | 4 recuadros de métricas destacadas con badges de variación + 2 tarjetas de análisis. |
| **10** | **Split UI Mockup** | Marco de navegador para captura de pantalla de sistema + tarjeta explicativa. |
| **11** | **Doble Captura de Pantalla** | Dos marcos de navegador lado a lado para comparaciones cruzadas. |
| **12** | **Plan Estratégico (5 Tarjetas)** | 4 tarjetas de esquina `#E6E7E8` + 1 tarjeta central con borde amarillo y resultado esperado. |
| **13** | **Split con Logo / Isotipo SVG** | Tarjeta visual con SVG vectorial a la izquierda + tarjetas de análisis a la derecha. |
| **14** | **Showcase Solo Captura UI** | Marco de navegador a pantalla completa para inspección de sistemas. |
| **15** | **Showcase Solo SVG / Diagrama** | Diapositiva a pantalla completa dedicada 100% a diagramas de arquitectura técnica. |
| **16** | **Cierre Corporativo Oficial** | Fondo `#E6E7E8` completo, logo DUOC centrado, banner oficial CNA 7 años y `#VerdaderamenteConectad@s`. |

---

## 🚀 Cómo Crear una Nueva Presentación

1. **Abre `index.html`** en cualquier navegador web moderno (Chrome, Safari, Edge, Firefox).
2. Para adaptar la presentación a tu tema:
   - Duplica `index.html` (ej. `mi_presentacion.html`).
   - Conserva los layouts que necesitas y elimina los que no uses.
   - Si necesitas añadir diapositivas adicionales, copia el bloque `<div class="slide ...">` correspondiente desde `templates/slide-types.html`.
3. **Si necesitas imágenes o SVGs propios**:
   - Crea una subcarpeta `assets/projects/<nombre-proyecto>/` y guarda allí tus capturas o diagramas.
   - **NUNCA mezcles archivos de proyectos dentro de `assets/brand/`**.

---

## 🎨 Paleta Institucional Obligatoria

- **Amarillo DUOC**: `#FFB71B` (pastillas de cabecera, barras de acento, viñetas activas y círculos de iconos).
- **Azul Marino DUOC**: `#002B49` (logotipo oficial, contrastes y títulos de tarjeta central).
- **Gris de Tarjeta**: `#E6E7E8` (**OBLIGATORIO en el 100% de las tarjetas y bloques de contenido**). NUNCA usar tarjetas azules o negras.
- **Gris Oscuro Texto**: `#262626` (títulos y viñetas para máxima legibilidad).
- **Gris Subtítulo**: `#7F8083` (categorías en mayúsculas de cabecera y metadatos).
- **Blanco**: `#FFFFFF` (fondo general del slide canvas).

---

## 🛡️ Reglas Anti-Desborde de Texto

- Todo bloque de contenido tiene `box-sizing: border-box; overflow: hidden; word-wrap: break-word;`.
- Redacta de forma ejecutiva: máximo 3 a 4 viñetas por tarjeta.
- Mantén siempre un margen de respiración visible de al menos 30px al pie de cada tarjeta.

---

## ⌨️ Atajos de Teclado y Modo Presentación

| Tecla / Acción | Función |
|:---|:---|
| `→`, `↓`, `Espacio`, `Enter` | Avanzar a la siguiente diapositiva |
| `←`, `↑`, `Backspace` | Volver a la diapositiva anterior |
| `F` | Activar / salir de **Pantalla Completa** |
| `O` o `Esc` | Abrir / cerrar la **Vista General** (grilla interactiva de miniaturas) |
| `Inicio` / `Fin` | Ir a la primera / última diapositiva |
| `Ctrl + P` / `Cmd + P` | **Exportar a PDF** (formato 16:9 horizontal, márgenes desactivados) |
