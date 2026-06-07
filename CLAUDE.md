# Especificação do Projeto: Guarda-Roupa Digital & Outfit Planner

## 1. Visão Geral
Aplicativo mobile nativo para gerenciamento de guarda-roupa pessoal, catalogação de peças de roupa com remoção automática de fundo e montagem/planejamento de looks (outfits). Todo o ecossistema é projetado para máxima performance visual, fluidez de interface e processamento assíncrono de imagens.

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

## 3. Arquitetura de Navegação (Bottom Navigation Bar)

### Aba 1: Home (Destaques e Recomendações)
- **Interface:** Layout limpo com uma saudação dinâmica baseada no horário do dia.
- **Componente Principal:** Um carrossel de rotação horizontal (`PageView.builder`) exibindo cartões de outfits montados de forma destacada.
- **Lógica:** Exibe combinações aleatórias bem-sucedidas ou prioriza outfits favoritados para engajar o usuário logo na abertura do app.

### Aba 2: Outfits (Catálogo Geral)
- **Interface:** Um Grid View responsivo mostrando todos os outfits salvos.
- **Funcionalidades Críticas:**
  - **Favoritar:** Ícone de coração que altera instantaneamente o booleano no banco de dados e joga o item para o topo (Mecanismo de fixação).
  - **Ordenação/Filtros:** Toggle ou Dropdown para alternar entre "Favoritos Primeiro" e "Mais Utilizados" (Ordenação decrescente baseada no contador de uso do look).
  - **Edição:** Um botão de ação em cada look que captura os IDs das peças componentes, empacota em um objeto de estado e despacha o usuário para a **Aba 4**, preenchendo a interface de montagem automaticamente.

### Aba 3: Captura (Câmera & Catalogação)
- **Interface:** Inicializa diretamente o plugin de câmera nativa em tela cheia.
- **Fluxo de Trabalho:**
  1. **Captura:** O usuário bate a foto da peça. O app exibe um indicador de carregamento (Spinner) enquanto envia o arquivo para a API Python.
  2. **Processamento:** A API Python processa a remoção de fundo e devolve o arquivo PNG limpo.
  3. **Formulário de Entrada:** A tela se divide. A metade superior exibe o preview perfeito da peça flutuando sem fundo. A metade inferior renderiza um formulário com:
     - `Campo de Texto`: Nome descritivo da peça.
     - `Dropdown/Segmented Control`: Categoria estrita (Camisa, Calça, Sapato, Cinto, Complemento).
  4. **Persistência:** Um botão destacado "Salvar Peça" grava o arquivo PNG no diretório local do dispositivo (`ApplicationDocumentsDirectory`) e insere os metadados no banco de dados local.

### Aba 4: Construtor (Montagem de Looks)
- **Interface:** Um canvas vertical estruturado imitando a anatomia humana. Exibe blocos vazios (Threshold Placeholders) pontilhados com ícones correspondentes a cada categoria (Camisa no topo, Calça no meio, Cinto na divisão, Sapatos na base, etc.).
- **Comportamento Interativo:**
  - Ao tocar em qualquer placeholder (ex: Camisa), um Modal inferior (`BottomSheet`) desliza exibindo em formato grid apenas as peças cadastradas pertencentes àquela categoria específica.
  - Ao selecionar a peça, ela assume o lugar do threshold visualmente através de uma animação suave de transição.
  - **Regra de Negócio:** O botão "Salvar Outfit" fica sempre ativo. O usuário pode salvar a combinação mesmo deixando thresholds vazios (ex: look sem cinto ou sem acessório complementar).
  - **Suporte a Edição:** Caso venha com dados de edição da Aba 2, os placeholders correspondentes já renderizam as imagens das roupas salvas previamente.

### Aba 5: Perfil e Analytics
- **Interface:** Visual limpo com avatar estilizado e nome de usuário.
- **Métricas:** Cards estatísticos alimentados por queries reativas (`Stream`) do banco de dados local:
  - Total exato de peças catalogadas.
  - Total de outfits criados.

---

## 4. Modelagem de Dados Relacional (Esquema SQLite)

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
