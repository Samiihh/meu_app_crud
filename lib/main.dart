import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

void main() {
  runApp(const MeuAppCrud());
}

//widget principal do aplicativo
class MeuAppCrud extends StatelessWidget {
  //super.key passa a chave (key) para classe pai StatelessWidget
  //Essa chave ela Ajuda o Flutter a identificar esse widget quando a árvore de widget muda.
  const MeuAppCrud({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelaPosts(),
    );
  }
}

class TelaPosts extends StatefulWidget {
  const TelaPosts({super.key});

  @override
  State<TelaPosts> createState() => _TelaPostsState();
}

class _TelaPostsState extends State<TelaPosts> {
  //Configurações do Dio
  //Dio é responsalvel por fazer as requisições HTTPpara api.

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    ),
  );

  // Lista onde vamos guardar os posts retornados pela api
  List<dynamic> _posts = [];

  // controla quando a tela esta carregando
  bool _carregando = false;

  // initState() roda uma unica vez quando o Widget é criado
  // È o lugar certo para executar ações iniciais do widget
  @override
  void initState() {
    super.initState();
    _buscarPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Posts'),

        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _buscarPosts),
        ],
      ),

      // Corpo da tela
      // Se tiver carregando, mostra loading.
      // Se não estiver, mostra lista de posts.
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? const Center(child: Text('Nenhum Post encontrado'))
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];

                return ListTile(
                  title: Text(post['title'] ?? 'Sem Titulo'),
                  subtitle: Text(post['body'] ?? 'Sem Conteudo'),

                  // Botão de deletar
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),

                    //ao clicar, chama a função deletar
                    onPressed: () {
                      _deletarPost(post['id'], index);
                    },
                  ),
                );
              },
            ),

      // Botão flutuante para criar um novo post
      floatingActionButton: FloatingActionButton(
        onPressed: _criarPost,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Read - Buscar posts da API
  Future<void> _buscarPosts() async {
    // setState avisar o flutter que os dados mudaram e a tela deve ser redesenhada
    setState(() {
      _carregando = true;
    });

    try {
      // Faz a requisição GET para buscar os posts.
      // Como ja temos a baseUrl configurada, usamos apenas /posts
      final response = await _dio.get('/posts');

      // Verificar se a tela ainda está montada antes de usar setState
      if (!mounted) return;

      setState(() {
        // A api retorna muitos posts.
        // Aqui pegamos apenas os 10 primeiros para tela não ficar gigante
        _posts = response.data.take(10).toList();
      });
    } on DioException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar posts: ${e.message}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _carregando = false;
      });
    }
  }

  //Create - Criar um novo post
  Future<void> _criarPost() async {
    try {
      // faz uma requisição Post enviando os dados novos post
      final response = await _dio.post(
        '/posts',
        data: {
          'title': 'Novinho agora',
          'body': 'Esse novissimos post chegou agora ja que o diego é chato',
          'userId': 1,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        setState(() {
          _posts.insert(0, response.data);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post criado com Sucesso')),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar post: ${e.message}')),
      );
    }
  }

  Future<void> _deletarPost(int id, int index) async {
    try {
      final response = await _dio.delete('/posts/$id');

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _posts.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deletado com sucesso')),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar post: ${e.message}')),
      );
    }
  }
}
