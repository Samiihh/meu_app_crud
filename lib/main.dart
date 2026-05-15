// Importa o Material Design do Flutter - biblioteca com componentes visuais prontos
import 'package:flutter/material.dart';

// Importa o Dio - biblioteca para fazer requisições HTTP (comunicação com APIs)
// Usamos o Dio porque é simples e poderoso para consumir APIs REST
import 'package:dio/dio.dart';

// Função principal - ponto de entrada do aplicativo
// runApp() inicia a aplicação e passa o widget raiz (MeuAppCrud)
void main() {
  runApp(const MeuAppCrud());
}

/// Widget principal do aplicativo
/// StatelessWidget = widget imutável (não muda de estado)
/// É usado para layouts e interfaces que não mudam dinamicamente
class MeuAppCrud extends StatelessWidget {
  /// super.key passa a chave (key) para a classe pai StatelessWidget
  /// A chave ajuda o Flutter a identificar esse widget quando a árvore de widgets muda
  /// Útil para manutenção de estado em listas dinâmicas
  const MeuAppCrud({super.key});

  /// Override do build method
  /// Este método constrói a interface visual do widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App CRUD', // Título do aplicativo
      debugShowCheckedModeBanner: false, // Remove o banner DEBUG no canto
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), // Define as cores principais como azul
      home: const TelaPosts(), // Define qual widget inicial será mostrado
    );
  }
}

/// Widget que gerencia a tela de posts
/// StatefulWidget = widget mutável que pode mudar seu estado
/// Usado quando precisamos atualizar a interface dinamicamente
class TelaPosts extends StatefulWidget {
  const TelaPosts({super.key});

  /// createState() retorna o estado associado a este widget
  /// Ela cria uma nova instância de _TelaPostsState
  @override
  State<TelaPosts> createState() => _TelaPostsState();
}

/// Estado da TelaPosts - aqui gerenciamos os dados e a lógica
/// O underscore (_) no início indica que é uma classe privada (interna)
class _TelaPostsState extends State<TelaPosts> {
  /// Configuração do Dio (cliente HTTP)
  /// Dio é a biblioteca responsável por fazer requisições HTTP para APIs
  /// Configuramos:
  ///   - baseUrl: URL base da API (JSONPlaceholder é uma API fake para testes)
  ///   - connectTimeout: tempo máximo para conectar (5 segundos)
  ///   - receiveTimeout: tempo máximo para receber resposta (5 segundos)
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com', // API fake para testes
      connectTimeout: const Duration(seconds: 5), // Timeout de conexão
      receiveTimeout: const Duration(seconds: 5), // Timeout de resposta
    ),
  );

  /// Lista que armazena os posts recebidos da API
  /// dynamic = tipo dinâmico (pode ser qualquer tipo)
  /// Usamos List<dynamic> porque a API retorna objetos (dicionários) com vários campos
  List<dynamic> _posts = [];

  /// Variável booleana que controla o estado de carregamento
  /// true = tela está carregando dados / false = carregamento concluído
  /// Usamos isso para mostrar um spinner (círculo de carregamento)
  bool _carregando = false;

  /// initState() é um ciclo de vida que executa uma ÚNICA vez
  /// Chamado quando o widget é criado pela primeira vez
  /// É o melhor lugar para:
  ///   - Fazer requisições iniciais à API
  ///   - Inicializar controladores
  ///   - Buscar dados do banco de dados local
  @override
  void initState() {
    super.initState(); // Chama o initState da classe pai
    _buscarPosts(); // Chama a função para buscar posts quando a tela abre
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// AppBar = barra superior da tela
      appBar: AppBar(
        title: const Text('Meus Posts'), // Título que aparece no topo
        // actions = lista de ícones/botões na direita do AppBar
        actions: [
          /// Botão de refresh (recarregar)
          /// ao clicar, chama _buscarPosts() novamente
          IconButton(icon: const Icon(Icons.refresh), onPressed: _buscarPosts),
        ],
      ),

      /// Corpo principal da tela (body)
      /// Estrutura condicional (ternária):
      ///   1. Se _carregando = true → mostra CircularProgressIndicator (spinner)
      ///   2. Se _posts está vazio → mostra mensagem "Nenhum Post encontrado"
      ///   3. Caso contrário → mostra ListView com a lista de posts
      body: _carregando
          // Mostra um spinner (círculo de carregamento)
          ? const Center(child: CircularProgressIndicator())
          // Se lista está vazia, mostra essa mensagem
          : _posts.isEmpty
          ? const Center(child: Text('Nenhum Post encontrado'))
          // ListView.builder = widget que cria uma lista rolável
          // Ele só renderiza os itens visíveis (eficiente mesmo com muitos itens)
          : ListView.builder(
              itemCount: _posts.length, // Número total de itens
              // itemBuilder = função que cria cada item da lista
              // Chamada uma vez para cada índice (0, 1, 2, ...)
              itemBuilder: (context, index) {
                // Pega o post no índice atual
                final post = _posts[index];

                // ListTile = widget que cria uma linha com title, subtitle e trailing
                return ListTile(
                  // title = texto principal
                  // ?? = operador de coalescência nula (se for null, usa o valor à direita)
                  title: Text(post['title'] ?? 'Sem Titulo'),
                  // subtitle = texto secundário (menor)
                  subtitle: Text(post['body'] ?? 'Sem Conteudo'),
                  // trailing = widget à direita (neste caso, o botão de deletar)
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    // onPressed = função executada ao clicar
                    onPressed: () {
                      // Chama a função deletar passando o ID e índice
                      _deletarPost(post['id'], index);
                    },
                  ),
                );
              },
            ),

      /// FloatingActionButton = botão redondo flutuante (FAB)
      /// Posicionado no canto inferior direito por padrão
      /// Usado para ações principais (criar, adicionar, etc.)
      floatingActionButton: FloatingActionButton(
        onPressed: _criarPost, // Ao clicar, chama a função de criar post
        child: const Icon(Icons.add), // Ícone de "+" (adicionar)
      ),
    );
  }

  /// [READ] - Busca posts da API
  /// Este é o "R" do CRUD (Create, Read, Update, Delete)
  ///
  /// Future<void> = função assíncrona (não bloqueia a interface)
  /// async/await = espera o resultado da API sem congelar a tela
  Future<void> _buscarPosts() async {
    // setState avisa ao Flutter que os dados mudaram e a tela deve ser redesenhada
    // Primeiro, ativa o indicador de carregamento
    setState(() {
      _carregando = true;
    });

    try {
      /// Faz uma requisição GET para buscar os posts
      /// GET = pede dados do servidor (sem enviar dados)
      /// A URL completa fica: https://jsonplaceholder.typicode.com/posts
      final response = await _dio.get('/posts');

      /// Verifica se a tela ainda está montada
      /// Importante: evita erros se o usuário sair da tela enquanto está carregando
      if (!mounted) return;

      /// Atualiza a lista com os dados recebidos
      setState(() {
        /// A API retorna muitos posts, então pegamos apenas os 10 primeiros
        /// .take(10) = pega os primeiros 10 itens
        /// .toList() = converte em uma lista
        _posts = response.data.take(10).toList();
      });
    } on DioException catch (e) {
      /// Captura erros de requisição HTTP
      /// (erro de conexão, timeout, erro do servidor, etc.)
      if (!mounted) return;

      /// ScaffoldMessenger.showSnackBar = mostra uma notificação na parte inferior
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar posts: ${e.message}')),
      );
    } finally {
      /// finally = executado SEMPRE, com ou sem erro
      /// Usamos para desativar o indicador de carregamento
      if (!mounted) return;
      setState(() {
        _carregando = false; // Para o spinner
      });
    }
  }

  /// [CREATE] - Cria um novo post na API
  /// Este é o "C" do CRUD (Create, Read, Update, Delete)
  ///
  /// POST = envia dados para o servidor (cria um novo recurso)
  Future<void> _criarPost() async {
    try {
      /// Faz uma requisição POST enviando dados de um novo post
      /// A URL completa fica: https://jsonplaceholder.typicode.com/posts
      /// data = corpo da requisição (os dados do novo post)
      final response = await _dio.post(
        '/posts',
        data: {
          'title': 'Novinho agora', // Título do post
          'body':
              'Esse novissimos post chegou agora ja que o diego é chato', // Conteúdo
          'userId': 1, // ID do usuário que criou o post
        },
      );

      /// Verifica se a tela ainda está montada
      if (!mounted) return;

      /// Verifica se o post foi criado com sucesso
      /// statusCode 201 = Created (recurso criado com sucesso)
      if (response.statusCode == 201) {
        /// Atualiza a lista adicionando o novo post no topo (índice 0)
        setState(() {
          _posts.insert(
            0,
            response.data,
          ); // Insert = insere na posição especificada
        });

        /// Mostra uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post criado com Sucesso')),
        );
      }
    } on DioException catch (e) {
      /// Captura erros de requisição HTTP
      if (!mounted) return;

      /// Mostra mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar post: ${e.message}')),
      );
    }
  }

  /// [DELETE] - Deleta um post da API
  /// Este é o "D" do CRUD (Create, Read, Update, Delete)
  ///
  /// Parâmetros:
  ///   - id = identificador único do post a deletar
  ///   - index = posição do post na lista local
  ///
  /// DELETE = remove um recurso do servidor
  Future<void> _deletarPost(int id, int index) async {
    try {
      /// Faz uma requisição DELETE para remover o post
      /// A URL fica: https://jsonplaceholder.typicode.com/posts/{id}
      /// Exemplo: /posts/1 deleta o post com ID 1
      final response = await _dio.delete('/posts/$id');

      /// Verifica se a tela ainda está montada
      if (!mounted) return;

      /// Verifica se a deleção foi bem-sucedida
      /// statusCode 200 = OK (operação bem-sucedida)
      if (response.statusCode == 200) {
        /// Remove o post da lista local
        setState(() {
          _posts.removeAt(
            index,
          ); // removeAt = remove o item no índice especificado
        });

        /// Mostra uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deletado com sucesso')),
        );
      }
    } on DioException catch (e) {
      /// Captura erros de requisição HTTP
      if (!mounted) return;

      /// Mostra mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar post: ${e.message}')),
      );
    }
  }
}
