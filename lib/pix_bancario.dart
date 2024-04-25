import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:uuid/uuid.dart';

void cabecalho() {
  stdout.write('\x1B[2J\x1B[0;0H'); //Limpa a tela do terminal
  print("Projeto Pix Bancário");
  print("Alunos: Caio Marcondes, Jean Augusto, Kevin Florindo, Vinicius Marcondes");
}

void menuPixBancario() async {
  String? menu;
  String nomeBanco, nomeAgencia, nome, sobrenome, chavePix, repetir;
  double limiteEspecial = 0.0, saldo = 0.0;
  Map<String, dynamic>? chaveExistente;

  do {
    //Define qual banco acessar
    do {
      cabecalho();
      print("\nBancos disponíveis:");
      print("- Banco 1\n- Banco 2\n- Banco 3\n- Banco 4\n- Banco 5");
      stdout.write("\nInsira o número do banco que deseja acessar: ");
      nomeBanco = stdin.readLineSync()!;
    } while (!(int.parse(nomeBanco) > 0 && int.parse(nomeBanco) <= 5));
    nomeBanco = "banco$nomeBanco";

    //Define qual agência acessar
    do {
      cabecalho();
      print("\nAgências disponíveis:");
      print("- Agência 1\n- Agência 2\n- Agência 3\n- Agência 4\n- Agência 5");
      stdout.write("\nInsira o número da agência que deseja acessar: ");
      nomeAgencia = stdin.readLineSync()!;
    } while (!(int.parse(nomeAgencia) > 0 && int.parse(nomeAgencia) <= 5));
    nomeAgencia = "agencia$nomeAgencia";

    //Variáveis de conexão ao banco e agência escolhidos
    final db = Db("mongodb://localhost:27017/$nomeBanco");
    final colecao = db.collection(nomeAgencia);

    //Abre a conexão
    await db.open();

    //Inputs para cadastrar o cliente
    do {
      cabecalho();
      print("\nCadastro de Cliente");

      do {
        stdout.write("\nNome: ");
        nome = stdin.readLineSync()!.toUpperCase();
      } while (nome.contains(RegExp(r"[0-9]"))); //Se conter número, repete a requisição

      do {
        stdout.write("Sobrenome: ");
        sobrenome = stdin.readLineSync()!.toUpperCase();
      } while (sobrenome.contains(RegExp(r"[0-9]"))); //Se conter número, repete a requisição

      do {
        chavePix = Uuid().v4();
        chaveExistente = await colecao.findOne(where.eq('uuid', chavePix));
      } while (chaveExistente != null); //Se a chave-pix já existir, gera uma nova
      print("\n" "Chave pix gerada: $chavePix");

      do {
        try {
          stdout.write("\nTerá limite especial? Se sim, insira o valor. Se não, insira \"0\".\nValor: ");
          limiteEspecial = double.parse(stdin.readLineSync()!);
        } on Exception {
          print("Valor inválido.");
        }
      } while (limiteEspecial < 0.0);

      do {
        try {
          stdout.write("\nSaldo inicial: ");
          saldo = double.parse(stdin.readLineSync()!);
        } on Exception {
          print("Valor inválido");
        }
      } while (saldo < 0.0);

      //Insere o documento na coleção
      await colecao.insertOne({
        "_id": ObjectId(),
        "nome": nome,
        "sobrenome": sobrenome,
        "chave_pix": chavePix,
        "limite_especial": limiteEspecial,
        "saldo": saldo,
        "transferencias": [],
      });

      stdout.write("\nRepetir outro cadastro na mesma agência e banco? [s/n]: ");
      repetir = stdin.readLineSync()!.toLowerCase();
    } while (repetir != "n");

    //Encerra a conexão
    await db.close();

    //Verifica se o usuário quer encerrar ou reiniciar
    stdout.write("\nSair ou fazer outro acesso? [sair/outro]: ");
    menu = stdin.readLineSync()!.toLowerCase();
  } while (menu != "sair");
}
