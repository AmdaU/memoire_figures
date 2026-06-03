# Réseaux de tenseurs (`figs/TNs/`)

> **English version follows** — [English](#english-version).

Ce dossier contient les diagrammes de réseaux de tenseurs du mémoire. Tous sont
dessinés à l'aide de la bibliothèque Asymptote partagée
[`figs/TN.asy`](../TN.asy), qui fournit une interface déclarative et réutilisable
pour décrire des tenseurs, leurs pattes (*legs*) et la façon dont ils se
contractent.

L'idée maîtresse : **on décrit la structure, pas le tracé**. On place des nœuds,
on leur donne des pattes nommées par des indices, et la bibliothèque se charge
de relier automatiquement les indices répétés, de laisser pendre les indices
libres, d'épaissir les arêtes selon leur dimension, etc.

## Utilisation de base

Chaque figure commence par les mêmes en-têtes (les chemins sont relatifs à la
racine du projet, car `asy` est lancé depuis la racine par le `Makefile`) :

```asy
include "figs/TN.asy";              // la bibliothèque
include "figs/AutoColors.asy.tmp";  // les pen issus du thème actif
defaultLegColor = textcolor;        // couleur du texte/des arêtes du thème
defaultpen(fontsize(12pt) + defaultLegColor);
```

Construire une figure :

```bash
make figs/TNs/ex.pdf
```

## Les trois objets

La bibliothèque définit trois `struct` et leurs constructeurs `make…`. On
n'instancie jamais les champs à la main : on passe par les constructeurs, qui
appliquent des valeurs par défaut raisonnables.

### `Leg` — une patte (un indice)

Une patte représente un indice tensoriel. C'est l'objet central : c'est le **nom
d'indice** (`idx`) qui pilote la contraction automatique.

| champ           | rôle |
|-----------------|------|
| `idx`           | nom de l'indice. Deux pattes portant le même `idx` sur deux tenseurs distincts **sont contractées** (reliées par une arête). |
| `dir`           | direction de la patte, en `pair` (p. ex. `(0,1)` = vers le haut). |
| `length`        | longueur d'une patte externe (pendante), en pt. |
| `dim`           | dimension de l'indice. Contrôle l'épaisseur de l'arête et la taille des flèches (échelle logarithmique). |
| `dag`           | marque la patte comme conjuguée ; inverse le côté de l'étiquette et le sens de la flèche. Géré par `dag()`. |
| `side`          | `+1` / `-1` : de quel côté de l'arête l'étiquette est placée. |
| `label`         | étiquette affichée ; défaut `$idx$`. |
| `color`         | couleur de l'arête. |
| `allowBezier`   | si `true`, une patte contractée peut être dessinée en courbe de Bézier (entre/sort selon `dir`) ; sinon l'arête est une droite nœud-à-nœud. |
| `labelStrength` | `0` aucune étiquette · `1` visible sur arête droite · `2` visible même sur une Bézier. |
| `align`         | alignement de l'étiquette (utile pour les Béziers). |
| `arrow`         | `0` aucune · `+1` dans le sens de `dir` · `-1` à contre-sens (`dag` inverse). |

Constructeur :

```asy
Leg makeLeg(string idx, bool dag=false, pair dir=(0,1), real length=externalLegLength,
            int side=+1, int dim=2, string label="", pen color=defaultLegColor,
            bool allowBezier=true, int labelStrength=1, pair align=(0,0), int arrow=0)
```

**`dag(Leg)`** renvoie une copie conjuguée : direction inversée, côté
d'étiquette inversé, sens de flèche inversé, drapeau `dag` basculé. C'est ainsi
qu'on relie proprement deux tenseurs : l'un porte `i`, l'autre `dag(i)`, et leurs
pattes pointent l'une vers l'autre.

### `Tensor` — un nœud

| champ            | rôle |
|------------------|------|
| `pos`            | position du nœud. |
| `label`          | étiquette au centre (LaTeX). |
| `color`          | couleur de remplissage. |
| `shape`          | forme du nœud (voir ci-dessous). |
| `r`              | rayon / demi-taille. |
| `dim`            | dimension, utilisée pour les fils d'identité (`id_h`/`id_v`). |
| `ratio`          | rapport largeur/hauteur pour `rect`. |
| `legs`           | tableau de `Leg`. |
| `blob`, `blob_ports`, `blob_label_pos` | pour la forme `blob` : chemin fermé arbitraire, points d'attache des pattes, position de l'étiquette. |
| `groups`         | rempli automatiquement au tracé : les pattes regroupées par direction. |

Constructeur :

```asy
Tensor makeTensor(string label, pair pos, Leg[] legs, pen color=defaultLegColor,
                  string shape="circle", real r=r, int dim=2, real ratio=1,
                  path blob=nullpath, pair[] blob_ports={}, pair blob_label_pos=(0,0))
```

**Formes disponibles** (`shape`) :

| forme      | description |
|------------|-------------|
| `circle`   | cercle (défaut). |
| `square`   | carré. |
| `diamond`  | losange. |
| `triangle` | triangle ; s'oriente vers la patte unique s'il n'y en a qu'une (isométries / vecteurs). |
| `rect`     | rectangle, largeur×`ratio`. |
| `id_h`     | trait horizontal (fil d'identité) ; épaisseur ∝ `dim`. |
| `id_v`     | trait vertical (fil d'identité). |
| `blob`     | forme libre définie par `blob` (un `path` fermé) ; les pattes s'attachent aux `blob_ports` dans l'ordre des `legs`. |

### `TensorNetwork` — un réseau

Un simple conteneur d'un tableau de `Tensor`. C'est l'unité que l'on dessine.

```asy
TensorNetwork net = makeTensorNetwork(new Tensor[] {A, B, C});
draw(net);
```

## Le mécanisme central : contraction par nom d'indice

Quand on dessine un `TensorNetwork`, la bibliothèque :

1. **Repère les indices partagés** — tout `idx` apparaissant sur deux tenseurs
   est considéré comme sommé et donne une **arête interne** entre eux
   (`findSharedIndices`).
2. **Laisse pendre les indices libres** — toute patte dont l'`idx` n'est pas
   partagé devient une **patte externe** (`danglingLegs`).
3. **Regroupe les pattes par direction** — sur un même nœud, plusieurs pattes
   pointant dans la même direction sont automatiquement étalées perpendiculai-
   rement pour ne pas se chevaucher (`groups` / `getGroupOffset`).
4. **Dessine** les arêtes, puis les pattes externes, puis les nœuds par-dessus.

On ne relie donc jamais deux tenseurs explicitement : on leur donne le même nom
d'indice (typiquement `i` sur l'un, `dag(i)` sur l'autre) et la connexion
apparaît.

## Dimension → épaisseur et flèches

L'épaisseur d'une arête encode la dimension de l'indice, sur une **échelle
logarithmique** : `get_width(dim) = linewidth(log10(dim) * legscale)`. De même,
la taille des flèches croît doucement avec `dim`. Cela permet de représenter
visuellement des indices de bond de tailles très différentes (utile pour les MPS
à dimension de lien croissante — voir `MPS_len_n.asy`). La variable globale
`legscale` règle la sensibilité de cette échelle.

## Béziers vs. droites

- `allowBezier=true` (défaut) : une arête interne est tracée comme une courbe
  qui sort du premier nœud selon sa `dir` et entre dans le second selon la
  sienne — pratique pour des géométries non alignées.
- `allowBezier=false` : l'arête est une droite nœud-à-nœud, et l'étiquette est
  placée perpendiculairement au milieu visible (hors des disques des nœuds).

## `contract()` — grossir un sous-réseau

`contract()` prend un `TensorNetwork` et renvoie **un seul `Tensor`** dont les
pattes sont exactement les pattes pendantes du réseau d'origine. Les indices
internes disparaissent ; les indices externes sont préservés (mêmes noms), si
bien que le tenseur grossi se recolle naturellement au reste du dessin. C'est
ainsi qu'on illustre une contraction par étapes (réseau complet → nœud unique) —
voir `weird_structure.asy`.

```asy
Tensor T = contract("$T'$", makeTensorNetwork(sousReseau), shape="square");
```

Sans `pos`, le nouveau nœud est placé au centroïde des tenseurs d'origine.

## Fonctions de tracé

| fonction                       | effet |
|--------------------------------|-------|
| `draw(Tensor)`                 | un nœud isolé avec toutes ses pattes en externe. |
| `draw(Tensor[])`               | plusieurs nœuds isolés. |
| `draw(TensorNetwork)`          | le réseau complet (contraction auto). |
| `shipoutWithMargin(m, bg)`     | exporte avec une marge uniforme `m` et un fond `bg`. À appeler en fin de fichier. |

Pour composer plusieurs diagrammes côte à côte (réseau ↔ réseau contracté, avec
une flèche entre les deux), on dessine dans des `picture` séparés puis on les
`attach` — voir `weird_structure.asy` et `MPS_len_n.asy`.

## Paramètres globaux ajustables

Modifiables en tête de fichier, avant de construire les objets :

| variable            | défaut | rôle |
|---------------------|--------|------|
| `lw`                | `2.5`  | épaisseur des contours et des pattes. |
| `r`                 | `12`   | rayon de nœud par défaut (pt). |
| `gap`               | `1`    | distance étiquette↔patte. |
| `legscale`          | `8.0`  | sensibilité de l'échelle dimension→épaisseur. |
| `externalLegLength` | `25`   | longueur par défaut d'une patte pendante. |
| `arrowScale`        | `1.0`  | facteur de taille des flèches. |
| `defaultLegColor`   | `black`| couleur par défaut des arêtes/étiquettes (mis à `textcolor` du thème). |

## Exemple minimal (`ex.asy`)

```asy
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;

Leg i = makeLeg("i", (1, 0), allowBezier=false);
Leg j = makeLeg("j", (0, 1), allowBezier=false);
Leg k = makeLeg("k", (1, 0), allowBezier=false);

Tensor A = makeTensor("$A$", (-60,0), new Leg[] {makeLeg("a",(0,1)), i, j}, primary);
Tensor B = makeTensor("$B$", (0,0),   new Leg[] {dag(i), k},               secondary);

draw(makeTensorNetwork(new Tensor[] {A, B}));
shipoutWithMargin(2*lw + 2*gap, background);
```

`A` et `B` partagent l'indice `i` (porté en `dag` par `B`) : une arête apparaît
entre eux. `a`, `j`, `k` restent des pattes pendantes.

## Galerie

Quelques figures notables de ce dossier :

- `ex.asy` — exemple minimal de contraction.
- `MPS.asy`, `MPS_len_n.asy` — *matrix product states* (chaîne + version à `n`
  sites avec « … »).
- `MPO.asy`, `MPO_len_n.asy` — *matrix product operators*.
- `svd.asy`, `svd_truncate.asy` — décomposition en valeurs singulières et
  troncature de lien.
- `orthogonality_center_*.asy` — centre d'orthogonalité d'un MPS et identités
  associées.
- `superop.asy` — superopérateur / forme de Kraus, illustre la forme `blob` et
  les fils d'identité.
- `sBs_contraction*.asy` — contraction du protocole sBs, avec et sans bruit.
- `weird_structure.asy` — réseau hexagonal arbitraire et son grossissement via
  `contract()`.

---

<a name="english-version"></a>

# Tensor networks (`figs/TNs/`)

This folder holds the tensor-network diagrams used in the thesis. They are all
drawn with the shared Asymptote library [`figs/TN.asy`](../TN.asy), which gives a
declarative, reusable interface for describing tensors, their legs, and how they
contract.

The guiding idea: **you describe the structure, not the drawing**. You place
nodes, give them legs named by indices, and the library automatically connects
repeated indices, dangles free indices, scales edge thickness by dimension, and
so on.

## Basic usage

Every figure starts with the same headers (paths are relative to the project
root, because the `Makefile` runs `asy` from there):

```asy
include "figs/TN.asy";              // the library
include "figs/AutoColors.asy.tmp";  // pens from the active theme
defaultLegColor = textcolor;        // theme text/edge color
defaultpen(fontsize(12pt) + defaultLegColor);
```

Build one figure:

```bash
make figs/TNs/ex.pdf
```

## The three objects

The library defines three `struct`s with `make…` constructors. Never set fields
by hand — go through the constructors, which apply sensible defaults.

### `Leg` — a leg (an index)

A leg represents a tensor index. It is the central object: the **index name**
(`idx`) drives automatic contraction.

| field           | role |
|-----------------|------|
| `idx`           | index name. Two legs sharing the same `idx` on two different tensors **are contracted** (joined by an edge). |
| `dir`           | leg direction, as a `pair` (e.g. `(0,1)` = up). |
| `length`        | length of an external (dangling) leg, in pt. |
| `dim`           | index dimension. Controls edge thickness and arrow size (log scale). |
| `dag`           | marks the leg as conjugated; flips the label side and arrow direction. Set via `dag()`. |
| `side`          | `+1` / `-1`: which side of the edge the label sits on. |
| `label`         | displayed label; defaults to `$idx$`. |
| `color`         | edge color. |
| `allowBezier`   | if `true`, a contracted leg may be drawn as a Bézier curve (leaving/entering along each `dir`); otherwise the edge is a straight node-to-node line. |
| `labelStrength` | `0` no label · `1` shown on straight edges · `2` shown even on a Bézier. |
| `align`         | label alignment (useful for Béziers). |
| `arrow`         | `0` none · `+1` along `dir` · `-1` against it (`dag` flips this). |

Constructor:

```asy
Leg makeLeg(string idx, bool dag=false, pair dir=(0,1), real length=externalLegLength,
            int side=+1, int dim=2, string label="", pen color=defaultLegColor,
            bool allowBezier=true, int labelStrength=1, pair align=(0,0), int arrow=0)
```

**`dag(Leg)`** returns a conjugated copy: direction reversed, label side
reversed, arrow direction reversed, `dag` flag toggled. This is how you cleanly
join two tensors: one carries `i`, the other `dag(i)`, and their legs point at
each other.

### `Tensor` — a node

| field            | role |
|------------------|------|
| `pos`            | node position. |
| `label`          | center label (LaTeX). |
| `color`          | fill color. |
| `shape`          | node shape (see below). |
| `r`              | radius / half-size. |
| `dim`            | dimension, used for identity wires (`id_h`/`id_v`). |
| `ratio`          | width/height ratio for `rect`. |
| `legs`           | array of `Leg`. |
| `blob`, `blob_ports`, `blob_label_pos` | for the `blob` shape: arbitrary closed path, leg attachment points, label position. |
| `groups`         | filled in automatically at draw time: legs grouped by direction. |

Constructor:

```asy
Tensor makeTensor(string label, pair pos, Leg[] legs, pen color=defaultLegColor,
                  string shape="circle", real r=r, int dim=2, real ratio=1,
                  path blob=nullpath, pair[] blob_ports={}, pair blob_label_pos=(0,0))
```

**Available shapes** (`shape`):

| shape      | description |
|------------|-------------|
| `circle`   | circle (default). |
| `square`   | square. |
| `diamond`  | diamond. |
| `triangle` | triangle; orients toward the single leg when there is exactly one (isometries / vectors). |
| `rect`     | rectangle, width×`ratio`. |
| `id_h`     | horizontal stroke (identity wire); thickness ∝ `dim`. |
| `id_v`     | vertical stroke (identity wire). |
| `blob`     | free shape given by `blob` (a closed `path`); legs attach to `blob_ports` in `legs` order. |

### `TensorNetwork` — a network

A plain container around an array of `Tensor`. It is the unit you draw.

```asy
TensorNetwork net = makeTensorNetwork(new Tensor[] {A, B, C});
draw(net);
```

## The core mechanism: contraction by index name

When you draw a `TensorNetwork`, the library:

1. **Finds shared indices** — any `idx` appearing on two tensors is treated as
   summed and produces an **internal edge** between them (`findSharedIndices`).
2. **Dangles free indices** — any leg whose `idx` is not shared becomes an
   **external leg** (`danglingLegs`).
3. **Groups legs by direction** — on a single node, several legs pointing the
   same way are automatically spread perpendicularly so they don't overlap
   (`groups` / `getGroupOffset`).
4. **Draws** edges first, then external legs, then the nodes on top.

So you never wire two tensors together explicitly: you give them the same index
name (typically `i` on one, `dag(i)` on the other) and the connection appears.

## Dimension → thickness and arrows

Edge thickness encodes the index dimension on a **logarithmic scale**:
`get_width(dim) = linewidth(log10(dim) * legscale)`. Arrow size likewise grows
gently with `dim`. This visually conveys bond indices of very different sizes
(handy for MPS with growing bond dimension — see `MPS_len_n.asy`). The global
`legscale` tunes the sensitivity of this mapping.

## Béziers vs. straight lines

- `allowBezier=true` (default): an internal edge is drawn as a curve that leaves
  the first node along its `dir` and enters the second along its own — handy for
  non-aligned geometries.
- `allowBezier=false`: the edge is a straight node-to-node line, and the label
  is placed perpendicular to the visible midpoint (outside the node disks).

## `contract()` — coarse-grain a sub-network

`contract()` takes a `TensorNetwork` and returns **a single `Tensor`** whose legs
are exactly the dangling legs of the original network. Internal indices vanish;
external indices are preserved (same names), so the coarse-grained tensor
re-attaches naturally to the rest of the drawing. This is how you illustrate a
step-by-step contraction (full network → single node) — see
`weird_structure.asy`.

```asy
Tensor T = contract("$T'$", makeTensorNetwork(subNetwork), shape="square");
```

Without a `pos`, the new node is placed at the centroid of the original tensors.

## Drawing functions

| function                       | effect |
|--------------------------------|--------|
| `draw(Tensor)`                 | a single node with all its legs dangling. |
| `draw(Tensor[])`               | several isolated nodes. |
| `draw(TensorNetwork)`          | the full network (auto-contraction). |
| `shipoutWithMargin(m, bg)`     | export with a uniform margin `m` and background `bg`. Call it at the end of the file. |

To compose several diagrams side by side (network ↔ contracted network, with an
arrow between them), draw into separate `picture`s and `attach` them — see
`weird_structure.asy` and `MPS_len_n.asy`.

## Adjustable global parameters

Set at the top of a file, before building objects:

| variable            | default | role |
|---------------------|---------|------|
| `lw`                | `2.5`   | outline and leg thickness. |
| `r`                 | `12`    | default node radius (pt). |
| `gap`               | `1`     | label↔leg distance. |
| `legscale`          | `8.0`   | sensitivity of the dimension→thickness scale. |
| `externalLegLength` | `25`    | default dangling-leg length. |
| `arrowScale`        | `1.0`   | arrow-size factor. |
| `defaultLegColor`   | `black` | default edge/label color (set to the theme's `textcolor`). |

## Minimal example (`ex.asy`)

```asy
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;

Leg i = makeLeg("i", (1, 0), allowBezier=false);
Leg j = makeLeg("j", (0, 1), allowBezier=false);
Leg k = makeLeg("k", (1, 0), allowBezier=false);

Tensor A = makeTensor("$A$", (-60,0), new Leg[] {makeLeg("a",(0,1)), i, j}, primary);
Tensor B = makeTensor("$B$", (0,0),   new Leg[] {dag(i), k},               secondary);

draw(makeTensorNetwork(new Tensor[] {A, B}));
shipoutWithMargin(2*lw + 2*gap, background);
```

`A` and `B` share index `i` (carried as `dag` by `B`): an edge appears between
them. `a`, `j`, `k` stay dangling.

## Gallery

A few notable figures in this folder:

- `ex.asy` — minimal contraction example.
- `MPS.asy`, `MPS_len_n.asy` — matrix product states (chain + `n`-site version
  with "…").
- `MPO.asy`, `MPO_len_n.asy` — matrix product operators.
- `svd.asy`, `svd_truncate.asy` — singular-value decomposition and bond
  truncation.
- `orthogonality_center_*.asy` — MPS orthogonality center and related
  identities.
- `superop.asy` — superoperator / Kraus form; showcases the `blob` shape and
  identity wires.
- `sBs_contraction*.asy` — sBs-protocol contraction, with and without noise.
- `weird_structure.asy` — arbitrary hexagonal network and its coarse-graining
  via `contract()`.
