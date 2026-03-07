# BKP Organiser

Um aplicativo de organização de backups e armazenamento de arquivos com uma estética **Cyberpunk / Terminal**, desenvolvido em Flutter. 

## 🚀 Funcionalidades Principais

- **Interface Cibernética:** Design focado em terminais dark-mode com textos em pixel-art/monospace (font: *Share Tech Mono*) e realces em verde neon.
- **Gerenciamento de Unidades:** Adicione SSDs, HDs ou Pendrives virtuais na tela principal (Root).
- **Sistema de Diretórios Completo:** Crie pastas e arquivos infinitamente aninhados dentro de suas unidades de armazenamento.
- **Protocolo de Realocação (MOVE):** Navegue recursivamente pelas suas pastas e mova arquivos entre diretórios perfeitamente usando o Modal Interativo.
- **Ação de Expurgo (DELETE):** Deslize para a esquerda para deletar arquivos e pastas nativamente.
- **Pesquisa Global de Arquivos:** Pesquise por qualquer arquivo ou pasta. Um modal listará os resultados mostrando os caminhos completos. Clique em `GO` para navegar magicamente até as entranhas do diretório onde o arquivo está guardado.
- **Armazenamento Offline Persistente:** Usa SQLite nativo no Android, iOS e MacOS de forma absurdamente rápida e eficiente.

## 🛠️ Como Clonar e Rodar este Projeto?

Este repositório contém arquivos ignorados pelo `.gitignore` (para manter o repo leve e limpo). Para rodar o aplicativo na sua máquina, siga os passos abaixo:

### Pré-requisitos
- Ter o **Flutter SDK** instalado (Versão 3.19.0 ou superior).
- Ter o **Dart SDK** instalado.

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/forgetsafetycloud/bkporganiser.git
   ```
2. **Navegue até a pasta do projeto:**
   ```bash
   cd bkporganiser
   ```
3. **Baixe as dependências:**
   Como pastas como `.dart_tool` e a pasta `build/` não sobem pro Git, você precisa restaurar os pacotes essenciais:
   ```bash
   flutter pub get
   ```
4. **Gere os ícones nas plataformas:** (Opcional, mas recomendado para build limpo em iOS/Android/MacOS)
   ```bash
   dart run flutter_launcher_icons
   ```
5. **Rode o App no seu dispositivo ou emulador:**
   ```bash
   flutter run
   ```

## 📱 Suporte
Compatível 100% com **MacOS**, **Android** (Hot Reload Funcional) e **iOS**. O aplicativo é bloqueado em visualização Vertical (Portrait Mode) para melhor ergonomia de Terminal móvel.
