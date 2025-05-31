# JubiTasks Mobile

Este repositório contém o código-fonte do aplicativo **JubiTasks Mobile**, a interface do usuário para a plataforma de lista de tarefas colaborativa desenvolvida pela equipe da Mega JR. Ele permite que os usuários criem, gerenciem e visualizem suas tarefas de forma intuitiva em dispositivos móveis.

---

## Tecnologias e Pacotes Utilizados

O aplicativo JubiTasks Mobile foi construído com **Flutter**, um SDK poderoso para desenvolvimento nativo multiplataforma. Abaixo estão os principais pacotes e suas finalidades:

### **Base e Design**
* **Flutter (SDK)**: O framework principal para construir o app em Android e iOS.
* **Estilo Visual**: Pacotes como `flutter_native_splash`, `flutter_launcher_icons`, `cupertino_icons`, `font_awesome_flutter`, `google_fonts`, `flutter_svg` e `lottie` foram usados para criar uma **identidade visual única**, com telas de splash, ícones personalizados, fontes e animações dinâmicas.
* **Animações e Carregamento**: `flutter_spinkit` oferece **indicadores de carregamento animados**, melhorando a experiência do usuário durante as operações.

### **Autenticação e Comunicação**
* **Firebase Core**: Essencial para a **integração do app com os serviços do Firebase**.
* **Autenticação**: `firebase_auth` e `google_sign_in` gerenciam o **login, registro e autenticação de usuários**, incluindo a opção de login com conta Google.
* **Comunicação com Backend**: O pacote `http` é usado para **realizar requisições à API RESTful do backend** do JubiTasks.

### **Gerenciamento de Dados e Navegação**
* **Gerenciamento de Estado**: `provider` é a biblioteca escolhida para o **gerenciamento de estado**, facilitando a atualização e compartilhamento de dados entre os componentes da interface.
* **Persistência Local**: `shared_preferences` permite o **armazenamento local de dados simples** no dispositivo, como preferências do usuário.
* **Navegação**: `go_router` é o pacote principal para gerenciar as **rotas e a navegação** entre as diferentes telas do aplicativo.
* **Utilitários**: `intl` (para formatação de datas e internacionalização) e `fluttertoast` (para exibir notificações temporárias) são usados para **funcionalidades auxiliares e feedback** ao usuário.

---

## Como o Projeto Foi Desenvolvido

O desenvolvimento do JubiTasks Mobile focou em uma arquitetura clara e componentes reutilizáveis para garantir uma base sólida e escalável:

1.  **Estrutura de Componentes**: O aplicativo é dividido em componentes reutilizáveis (widgets) para construir interfaces de usuário complexas de forma modular.
2.  **Fluxo de Autenticação**: Implementamos um fluxo de autenticação completo usando Firebase, incluindo telas de login, registro e recuperação de senha, além de integração com login do Google.
3.  **Consumo da API RESTful**: A comunicação com o backend do JubiTasks é feita através de requisições HTTP, utilizando o pacote `http` para interagir com os endpoints de gerenciamento de tarefas.
4.  **Gerenciamento de Estado com Provider**: O `provider` é utilizado para gerenciar o estado da aplicação, garantindo que os dados, como a lista de tarefas ou informações do usuário, sejam atualizados e compartilhados eficientemente entre as telas.
5.  **Navegação Declarativa**: O `go_router` foi escolhido para gerenciar a navegação, permitindo rotas declarativas e facilitando a organização do fluxo de navegação do aplicativo.
6.  **Design e Experiência do Usuário**: Uma atenção especial foi dada à aparência, utilizando `google_fonts`, `font_awesome_flutter` e animações Lottie para criar uma interface agradável e interativa.
7.  **Persistência Local**: `shared_preferences` é usado para armazenar dados leves e persistentes, como configurações de usuário.

---

## Como Executar o Projeto Localmente

Para rodar o aplicativo JubiTasks Mobile em seu ambiente de desenvolvimento, siga os passos abaixo:

1.  **Pré-requisitos**:
    * **Flutter SDK** (versão recomendada: 3.x.x ou superior)
    * Um editor de código (VS Code, Android Studio) com o plugin Flutter
    * Um emulador Android/iOS ou um dispositivo físico conectado.
    * **Configuração do Firebase**: Certifique-se de que seu projeto Flutter esteja conectado ao seu projeto Firebase. Siga a documentação oficial do Firebase para adicionar o arquivo `google-services.json` (Android) e/ou `GoogleService-Info.plist` (iOS) aos seus diretórios.

2.  **Clonar o Repositório**:
    ```bash
    git clone https://github.com/MEGA-JR-Grupo-3/megajr-mobile
    cd megajr-mobile
    ```

3.  **Instalar Dependências**:
    ```bash
    flutter pub get
    ```

4.  **Executar Geradores de Build (se aplicável)**:
    Se você usa `build_runner` para geração de código (ex: freezed, json_serializable), execute:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

5.  **Configurar o `flutter_native_splash` e `flutter_launcher_icons`**:
    Após modificar as imagens de splash e ícone, execute os comandos para gerá-las:
    ```bash
    flutter pub run flutter_native_splash:create
    flutter pub run flutter_launcher_icons:main
    ```

6.  **Rodar o Aplicativo**:
    ```bash
    flutter run
    ```
    Selecione o emulador ou dispositivo desejado.
