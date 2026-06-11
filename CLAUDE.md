# Especificação do Projeto: Guarda-Roupa Digital & Outfit Planner

## 1. Visão Geral
Aplicativo mobile nativo para gerenciamento de guarda-roupa pessoal, catalogação de peças de roupa com remoção opcional de fundo e montagem/planejamento de looks (outfits). Todo o ecossistema é projetado para máxima performance visual, fluidez de interface e processamento assíncrono de imagens.

## 2. Stack Tecnológica Justificada

### Front-end Mobile: Flutter & Dart
- **Por que é a melhor opção?**
  - **Performance Gráfica Nativa:** O motor de renderização Impeller do Flutter garante animações a 60/120 FPS estáveis. Como o app depende de carrosséis horizontais, grids densos de imagens de alta resolução e overlays de peças (camadas empilhadas), o Flutter gerencia o canvas gráfico de forma muito superior a soluções baseadas em pontes JavaScript.
  - **Manipulação Avançada de Imagens:** Flutter oferece controle granular sobre cache de imagem (`ExtendedImage` ou `CachedNetworkImage`) e renderização de imagens com transparência (PNG/WebP), essencial após a remoção de fundo.
  - **Consistência de UI:** Garante que os thresholds (placeholders) e as camadas de roupas fiquem milimetricamente idênticas no Android e iOS.

### Back-end / Microserviço de Processamento: Python (FastAPI + rembg)
- **Por que é a melhor opção?**
  - **Ecossistema de IA/Visão Computacional:** A remoção de fundo com alta qualidade exige redes neurais convolucionais (U2NET). Python é a linguagem soberana para isso. A biblioteca `rembg` encapsula esses modelos ONNX com excelente precisão.
  - **Assincronismo com FastAPI:** Cria rotas extremamente rápidas e leves para receber os bytes da imagem tirada pelo celular, processar na IA e devolver o PNG transparente sem bloquear a aplicação.

### Banco de Dados Local: SQLite (via Drift/Moor ou Isar NoSQL)
- **Por que é a melhor opção?**
  - **Drift (SQLite):** Permite modelar a relação muitos-para-muitos estruturada entre Peças e Outfits. Suporta consultas complexas com agregação de forma extremamente rápida, ideal para computar as estatísticas do perfil e aplicar os filtros de ordenação ("Mais Utilizados").

---

## 3. Design System & Regras Visuais

### Paleta de Cores
- **Primárias:** Branco e Azul Escuro.
- **Tema:** O app suporta Tema Claro e Tema Escuro, alternáveis na **Aba 5 (Perfil)**. Usar `ThemeMode` do Flutter gerenciado por estado global (ex: Provider ou Riverpod).
- **Favorito:** Ícone de **Estrela** (substitui coração). Estrela **amarela** quando ativo, cinza/contornada quando inativo.

### Layout Global
- **Header:** Todas as abas possuem um header fino no topo com o título da aba centralizado.
- **Bottom Navigation Bar:** Altura reduzida em relação ao padrão do Material. Labels curtos e ícones pequenos.
- **Botão "Salvar Outfit":** Tamanho horizontal reduzido (não ocupa toda a largura). Sem ícone de disquete — apenas texto.

---

## 4. Arquitetura de Navegação (Bottom Navigation Bar)

### Aba 1: Home (Destaques e Recomendações)
- **Interface:** Layout limpo com uma saudação dinâmica baseada no horário do dia.
- **Componente Principal:** Um carrossel de rotação horizontal (`PageView.builder`) exibindo cartões de outfits montados de forma destacada.
- **Lógica:** Exibe combinações aleatórias bem-sucedidas ou prioriza outfits favoritados para engajar o usuário logo na abertura do app.

### Aba 2: Outfits (Catálogo Geral)
- **Interface:** Um Grid View responsivo mostrando todos os outfits salvos.
- **Funcionalidades Críticas:**
  - **Favoritar:** Ícone de **estrela** que altera instantaneamente o booleano no banco de dados e joga o item para o topo (Mecanismo de fixação). Estrela amarela = ativo.
  - **Excluir:** Cada card de outfit possui opção de exclusão (ex: botão de lixeira ou swipe-to-delete), que remove o outfit do banco de dados com confirmação via dialog.
  - **Ordenação/Filtros:** Toggle ou Dropdown para alternar entre "Favoritos Primeiro" e "Mais Utilizados" (Ordenação decrescente baseada no contador de uso do look).
  - **Edição:** Um botão de ação em cada look que captura os IDs das peças componentes, empacota em um objeto de estado e despacha o usuário para a **Aba 4**, preenchendo a interface de montagem automaticamente.

### Aba 3: Captura (Câmera & Catalogação)
- **Interface:** Exibe um seletor de origem da imagem: **Câmera** ou **Galeria**.
- **Fluxo de Trabalho:**
  1. **Seleção de Origem:** O usuário escolhe entre abrir a câmera nativa ou selecionar uma imagem da galeria do dispositivo.
  2. **Pergunta de Remoção de Fundo:** Após a escolha/captura da imagem, o app exibe um dialog perguntando: **"Deseja remover o fundo desta imagem?"** com opções **Sim** e **Não**.
     - **Sim:** O app exibe um Spinner enquanto envia a imagem para a API Python. A API devolve o PNG sem fundo.
     - **Não:** A imagem original é usada diretamente, sem chamada à API.
  3. **Formulário de Entrada:** A tela se divide. A metade superior exibe o preview da peça (com ou sem fundo conforme a escolha). A metade inferior renderiza um formulário com:
     - `Campo de Texto`: Nome descritivo da peça.
     - `Dropdown/Segmented Control`: Categoria estrita (Chapéu/Boné, Camisa, Blusa/Jaqueta, Cinto, Calça, Sapato, Complemento).
  4. **Persistência:** Um botão destacado "Salvar Peça" grava o arquivo PNG no diretório local do dispositivo (`ApplicationDocumentsDirectory`) e insere os metadados no banco de dados local.

### Aba 4: Construtor (Montagem de Looks)
- **Interface:** Um canvas vertical estruturado imitando a anatomia humana. Exibe blocos vazios (Threshold Placeholders) pontilhados com ícones correspondentes a cada categoria, na seguinte **ordem de cima para baixo:**
  1. **Chapéu/Boné** (topo)
  2. **Camisa** (centro-topo) | **Blusa/Jaqueta** (ao lado direito da Camisa)
  3. **Cinto** (divisão)
  4. **Calça** (centro)
  5. **Sapato** (base)
  - **Complementos** ficam agrupados em coluna centralizada à esquerda do canvas.
- **Comportamento Interativo:**
  - Ao tocar em qualquer placeholder, um Modal inferior (`BottomSheet`) desliza exibindo em formato grid apenas as peças cadastradas pertencentes àquela categoria específica.
  - Ao selecionar a peça, ela assume o lugar do threshold visualmente através de uma animação suave de transição.
  - **Regra de Negócio:** O botão **"Salvar Outfit"** fica sempre ativo. O usuário pode salvar a combinação mesmo deixando thresholds vazios (ex: look sem cinto ou complemento). O botão tem largura reduzida (não ocupa a tela toda) e **não possui ícone de disquete**.
  - **Suporte a Edição:** Caso venha com dados de edição da Aba 2, os placeholders correspondentes já renderizam as imagens das roupas salvas previamente.

### Aba 5: Perfil e Analytics
- **Interface:** Visual limpo com avatar estilizado e nome de usuário.
- **Métricas:** Cards estatísticos alimentados por queries reativas (`Stream`) do banco de dados local:
  - Total exato de peças catalogadas.
  - Total de outfits criados.
- **Configurações:** Contém o toggle de **Tema Claro / Tema Escuro** que altera o `ThemeMode` globalmente.

---

## 5. Modelagem de Dados Relacional (Esquema SQLite)

### Tabela: `clothing_items`
- `id`: TEXT (UUID) [Primary Key]
- `name`: TEXT
- `image_path`: TEXT (Caminho local do arquivo PNG sem fundo)
- `category`: TEXT (Enum: camisa, calca, sapato, cinto, complemento)
- `date_added`: INTEGER (Timestamp)

### Tabela: `outfits`
- `id`: TEXT (UUID) [Primary Key]
- `name`: TEXT
- `is_favorite`: INTEGER (Boolean: 0 ou 1)
- `usage_count`: INTEGER (Default 0)
- `date_created`: INTEGER (Timestamp)

### Tabela: `outfit_items` (Tabela de Ligação / Associação)
- `outfit_id`: TEXT [Foreign Key -> outfits(id) ON DELETE CASCADE]
- `item_id`: TEXT [Foreign Key -> clothing_items(id) ON DELETE CASCADE]
- *Chave Primária Composta:* (`outfit_id`, `item_id`)

## Development Rules (Token-Saving)
- **Do not** write extensive comments or documentation inside code unless explicitly asked.
- **Do not** refactor unrelated files. Focus strictly on the requested scope.
- **Always** run relevant tests before declaring a task finished.
- If a compilation or test error occurs, analyze the stack trace completely before changing code.

# Claude Project Knowledge & Rules

## Project Overview
- **App Name:** OutfitApp (Digital Wardrobe & Outfit Planner)
- **Stack:** Flutter 3.44+ / Dart ^3.12 (Material 3, Impeller)
- **State Management:** Riverpod with Code Generation (`@riverpod`, `riverpod_annotation`)
- **Database:** Local SQLite via Drift (Reactive with Streams), schemaVersion = 2
- **Backend Service:** Python + FastAPI + rembg (U²-Net/ONNX) for background removal via HTTP bytes.

---

## Architectural Guidelines
- **Pattern:** MVC-ish (views/ -> controllers/ -> database/ & services/)
- **State & Data Flow:** UI must consume data via reactive Streams exposed by Drift DAOs. State modifications must trigger automatic UI updates through Riverpod providers.
- **Navigation:** Controlled strictly via `nav_controller` using an `IndexedStack` + `NavigationBar` (5 tabs).

---

## Technical Code Rules
- **Riverpod Syntax:** NEVER write legacy manual providers. ALWAYS use the modern code generation syntax with `@riverpod` annotations.
- **Asynchronous Code & I/O:** All HTTP calls, camera operations, and file storage (`image_storage_service.dart`) MUST be wrapped in `try-catch` blocks. Handle errors gracefully by propagating failure states to the UI; never let the app crash due to network/IO failures.
- **Scope Creep Guard:** Do not refactor or modify files outside the explicit prompt scope unless strictly required to fix compilation errors. 

---

## Design System (Editorial & Minimalist Aesthetic)
- **Geometry:** Strict semi-sharp corners. Apply `BorderRadius.circular(4)` to all cards, buttons, inputs, and containers. Modals/bottom sheets use `BorderRadius.circular(6)`. Never use highly rounded or circular corners unless it is for avatars.
- **Effects:** No artificial effects. Set `elevation: 0` globally. Do NOT use gradients or diffuse drop shadows. 
- **Contrast & Styling:** Contrast must be achieved via fine borders (`outlineVariant`), font weights, and solid colors. Use explicit `letterSpacing` on titles and labels to maintain the editorial print look.
- **Palette:** Deep Dark Blue (`#14213D`), Pure White, and Dark Background (`#0B1426`). Shared uniform layout language across Light/Dark modes via `_buildTheme(brightness)` in `app.dart`.

---

## Output Restrictions (Token Efficiency)
- **Minimalist Diffs:** When modifying code, output ONLY the modified code lines or specific file diffs. Never rewrite a whole file if only minor lines changed.
- **No Fluff:** Do not provide verbose text explanations, introductions, or conversational filler after generating code blocks. Go straight to execution. 