# OutfitApp — Guarda-Roupa Digital & Outfit Planner

Aplicativo Flutter para catalogar peças de roupa (com remoção opcional de fundo
por IA) e montar looks posicionando as peças num canvas com anatomia humana.
Os dados são 100% locais (SQLite via Drift); apenas a remoção de fundo usa um
microserviço Python (FastAPI + rembg / U²-Net).

## Stack
- **Flutter 3.44+ / Dart ^3.12** (Material 3, Impeller)
- **Riverpod (code generation)** — todo estado usa `@riverpod`
- **Drift (SQLite reativo)** — DAOs expõem `Stream`s
- **Backend:** Python + FastAPI + rembg (`backend/main.py`)

## Arquitetura
Padrão em camadas com fluxo reativo:

```
views/ (UI)  →  controllers/ (Riverpod)  →  database/daos (Drift)  →  SQLite
                       │                          ↑ Streams reativos
                       └──→ services/ (HTTP rembg, storage de imagem)
```

- A UI consome `Stream`s do Drift via providers Riverpod (atualização automática).
- Navegação por `IndexedStack` + `NavigationBar` (5 abas), controlada pelo índice
  em `CurrentTabIndex`.
- Imagens são salvas em arquivo (`ApplicationDocumentsDirectory`); o banco guarda
  apenas o caminho.

### Pastas
- `lib/config/` — `AppConfig` (URL/timeout do backend).
- `lib/models/` — tabelas Drift e o value object `ItemTransform` (layout normalizado).
- `lib/database/` — `AppDatabase`, migrações e DAOs.
- `lib/controllers/` — providers Riverpod (todos codegen).
- `lib/services/` — remoção de fundo (HTTP) e persistência de imagem.
- `lib/views/` — uma pasta por aba (`home`, `outfits`, `capture`, `constructor`, `profile`).
- `lib/widgets/` — `outfit_layout_preview.dart` (render/preview/export do look).
- `backend/` — microserviço FastAPI de remoção de fundo.

## Providers (Riverpod codegen)
- `sharedPreferencesProvider` — instância injetada no `main` via override.
- `themeModeControllerProvider` / `profileControllerProvider` — tema e perfil
  (lidos de `SharedPreferences`).
- `appDatabaseProvider` — instância do banco.
- `clothingItemsProvider`, `clothingByCategoryProvider`, `recentClothingProvider`,
  `outfitPlacementsProvider`, `clothingControllerProvider`.
- `outfitsSortedProvider`, `recentOutfitsProvider`, `totalClothingItemsProvider`,
  `totalOutfitsProvider`, `outfitControllerProvider`.
- `currentTabIndexProvider`, `constructorControllerProvider`.

## Esquema do banco (schemaVersion 4)
`ON DELETE CASCADE` exige `PRAGMA foreign_keys = ON` (aplicado em `beforeOpen`).

### `clothing_items`
| coluna      | tipo    | notas                         |
|-------------|---------|-------------------------------|
| id          | TEXT PK | UUID                          |
| name        | TEXT    |                               |
| image_path  | TEXT    | caminho local do arquivo      |
| category    | TEXT    | ver categorias abaixo         |
| color       | TEXT?   | chave da paleta (opcional)    |
| date_added  | INTEGER | timestamp (ms)                |

### `outfits`
| coluna       | tipo    | notas                    |
|--------------|---------|--------------------------|
| id           | TEXT PK | UUID                     |
| name         | TEXT    |                          |
| is_favorite  | INTEGER | 0/1 (default 0)          |
| date_created | INTEGER | timestamp (ms)           |

### `outfit_items` (ligação N:N, PK composta `outfit_id` + `item_id`)
| coluna    | tipo    | notas                                    |
|-----------|---------|------------------------------------------|
| outfit_id | TEXT FK | → outfits(id) ON DELETE CASCADE          |
| item_id   | TEXT FK | → clothing_items(id) ON DELETE CASCADE   |
| center_x  | REAL    | posição normalizada 0..1 (default 0.5)   |
| center_y  | REAL    | posição normalizada 0..1 (default 0.5)   |
| item_size | REAL    | lado como fração da largura (0 = legado) |
| z_index   | INTEGER | ordem de empilhamento                    |

### `outfit_usages` (histórico de uso — fonte única das estatísticas)
| coluna    | tipo    | notas                              |
|-----------|---------|------------------------------------|
| id        | TEXT PK | UUID                               |
| outfit_id | TEXT FK | → outfits(id) ON DELETE CASCADE    |
| used_at   | INTEGER | timestamp (ms); só data se `has_time` = 0 |
| has_time  | INTEGER | 0/1 — se o horário foi informado   |

**Categorias** (enum `ClothingCategory`, gravadas como string):
`chapeu`, `camisa`, `blusa`, `cinto`, `calca`, `sapato`, `acessorios`.

**Cores** (paleta fixa `kItemColors`, chave gravada como string): `preto`,
`branco`, `cinza`, `azul`, `vermelho`, `verde`, `amarelo`, `marrom`, `rosa`,
`laranja`, `roxo`, `bege`.

> **Uso é derivado, não contado.** Não existe coluna `usage_count`: "Mais Usados",
> calendário e todas as estatísticas são derivados de `outfit_usages`.

## Funcionalidades

- **Busca global** (ícone na aba Outfits): peças e outfits por nome, instantânea,
  case-insensitive e parcial; guarda as 3 últimas buscas.
- **Calendário** (Perfil): registra uso por data (horário opcional), filtra por
  look e lista os usos do dia. Detalhe do outfit mostra histórico, último e total.
- **Estatísticas** (Perfil): totais, distribuição por categoria/cor, peças mais
  usadas e nunca usadas, crescimento do acervo por mês.
- **Closet Replay** (Perfil): peças/outfits esquecidos, mais repetidos, rotação,
  cor/categoria mais e menos usadas, atividade semanal/mensal e meta mensal visual.

## Executando

### App
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Backend (remoção de fundo)
```bash
cd backend
python -m venv venv && source venv/bin/activate
pip install fastapi uvicorn rembg
uvicorn main:app --host 0.0.0.0 --port 8000
```
Ajuste `AppConfig.backgroundRemovalBaseUrl` (`lib/config/app_config.dart`) para o
IP da máquina host.

### Testes
```bash
flutter test
```
Cobrem `ItemTransform`, posicionamento normalizado (`fitOutfitCanvas`), DAOs,
`saveOutfit` (criação/edição), `ConstructorController` e os cascades de FK.
