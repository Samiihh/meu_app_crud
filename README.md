# App CRUD com Flutter 📱

Um projeto educacional desenvolvido para ensinar alunos como **consumir APIs REST com Flutter**.

## 📚 Sobre o Projeto

Este projeto foi criado como material didático para demonstrar os conceitos fundamentais de consumo de APIs em aplicações Flutter. Os alunos aprendem na prática como:

- ✅ Fazer requisições HTTP (GET, POST, DELETE)
- ✅ Gerenciar estado com `StatefulWidget`
- ✅ Usar a biblioteca `Dio` para requisições HTTP
- ✅ Implementar operações CRUD (Create, Read, Update, Delete)
- ✅ Tratamento de erros com try/catch
- ✅ Mostrar feedback ao usuário com SnackBar
- ✅ Usar widgets como ListView, AppBar, FloatingActionButton

## 🚀 Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento mobile
- **Dart** - Linguagem de programação
- **Dio** - Biblioteca HTTP para requisições de API
- **JSONPlaceholder** - API fake para testes (dados de exemplo)

## 📋 Funcionalidades (CRUD)

### 📖 READ (Leitura)
- Busca todos os posts da API ao abrir a tela
- Carrega os 10 primeiros posts
- Mostra indicador de carregamento enquanto busca
- Botão de refresh para recarregar dados

### ➕ CREATE (Criação)
- Botão flutuante (+) para criar novos posts
- Envia dados para a API via POST
- Adiciona novo post no topo da lista
- Mostra confirmação de sucesso

### 🗑️ DELETE (Exclusão)
- Botão de lixeira em cada post
- Remove o post da API via DELETE
- Remove o post da lista local
- Mostra confirmação de exclusão

## 🛠️ Como Usar

### 1. **Instalar dependências**
```bash
flutter pub get
```

### 2. **Executar o app**
```bash
flutter run
```

### 3. **Compilar para produção**
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Arquivo principal com toda a lógica
```

## 🔍 Conceitos-Chave Abordados

### 1. **async/await**
Padrão para trabalhar com operações assíncronas sem bloquear a interface
```dart
Future<void> _buscarPosts() async {
  final response = await _dio.get('/posts');
}
```

### 2. **setState()**
Notifica o Flutter que o estado mudou e redesenha a tela
```dart
setState(() {
  _posts = response.data.take(10).toList();
});
```

### 3. **try/catch/finally**
Tratamento robusto de erros
```dart
try {
  // fazer requisição
} on DioException catch (e) {
  // tratar erro
} finally {
  // executar sempre
}
```

### 4. **Widgets Principais**
- `Scaffold` - estrutura base da tela
- `AppBar` - barra superior
- `ListView.builder` - lista dinâmica
- `FloatingActionButton` - botão de ação principal
- `CircularProgressIndicator` - indicador de carregamento

## 🌐 API Utilizada

**JSONPlaceholder** - https://jsonplaceholder.typicode.com

API fake gratuita perfeita para aprender consumo de APIs. Endpoints utilizados:
- `GET /posts` - Lista todos os posts
- `POST /posts` - Cria um novo post
- `DELETE /posts/{id}` - Deleta um post

## 💡 Pontos de Aprendizagem

1. **Dio Configuration** - Como configurar base URL e timeouts
2. **Requisições HTTP** - GET, POST, DELETE
3. **Async/Await** - Programação assíncrona em Dart
4. **State Management** - Gerenciar dados com setState
5. **Error Handling** - Tratamento de erros e exceções
6. **User Feedback** - SnackBar e CircularProgressIndicator
7. **Conditional Rendering** - Mostrar diferentes widgets baseado em estado
8. **List Operations** - take(), insert(), removeAt()

## 📚 Recursos Educacionais

- [Documentação oficial do Flutter](https://docs.flutter.dev/)
- [Documentação do Dio](https://pub.dev/packages/dio)
- [REST APIs](https://developer.mozilla.org/en-US/docs/Glossary/REST)
- [JSONPlaceholder API](https://jsonplaceholder.typicode.com/)

## ✏️ Comentários no Código

Todo o código em `lib/main.dart` contém comentários detalhados explicando cada conceito, widget e operação. Recomenda-se ler linha por linha para melhor compreensão.

## 🎯 Próximos Passos (Desafios)

1. **Implementar UPDATE** - Adicionar edição de posts existentes
2. **Melhorar UI/UX** - Adicionar animações e efeitos visuais
3. **Persistência Local** - Salvar dados localmente com SQLite
4. **Autenticação** - Implementar login na API
5. **Paginação** - Carregar mais posts conforme o usuário rola
6. **Offline First** - Trabalhar sem conexão e sincronizar depois

## 📝 Notas Importantes

- A JSONPlaceholder é uma API fake, então as alterações não persistem
- Todos os comentários no código explicam o "por quê" de cada decisão
- O projeto usa `mounted` para evitar erros ao atualizar widgets destruídos
- Timeouts de 5 segundos previnem travamentos da interface

## 👨‍🏫 Para Instrutores

Este projeto foi projetado para ser:
- **Simples** - Uma única tela com lógica clara
- **Documentado** - Comentários explicam cada conceito
- **Prático** - Alunos aprendem fazendo
- **Extensível** - Fácil adicionar novas funcionalidades

Sinta-se livre para modificar e adaptá-lo às suas necessidades de ensino!

---

**Desenvolvido como material educacional para ensino de Flutter e consumo de APIs REST**
