import 'package:flutter_test/flutter_test.dart';
import 'package:quickfreela_cliente/domain/entities/criar_solicitacao_input.dart';
import 'package:quickfreela_cliente/domain/entities/proposta.dart';
import 'package:quickfreela_cliente/domain/entities/solicitacao.dart';
import 'package:quickfreela_cliente/domain/repositories/quickfreela_repository.dart';
import 'package:quickfreela_cliente/main.dart';

void main() {
  testWidgets('renderiza painel do cliente', (tester) async {
    await tester.pumpWidget(
      QuickFreelaClienteApp(repository: _FakeRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('QuickFreela'), findsOneWidget);
    expect(find.text('Corrigir landing page'), findsOneWidget);
  });
}

class _FakeRepository implements QuickFreelaRepository {
  final _solicitacao = const Solicitacao(
    id: 1,
    clienteId: 1,
    titulo: 'Corrigir landing page',
    descricao: 'Ajustar responsividade e copy principal.',
    categoria: 'programacao',
    orcamento: 180,
    status: 'aberta',
    prazoEntrega: '2026-06-30',
    clienteNome: 'Ana Cliente',
  );

  @override
  Future<Solicitacao> atualizarStatus(int solicitacaoId, String status) async {
    return Solicitacao(
      id: _solicitacao.id,
      clienteId: _solicitacao.clienteId,
      titulo: _solicitacao.titulo,
      descricao: _solicitacao.descricao,
      categoria: _solicitacao.categoria,
      orcamento: _solicitacao.orcamento,
      status: status,
    );
  }

  @override
  Future<Solicitacao> buscarSolicitacao(int id) async => _solicitacao;

  @override
  Future<Solicitacao> criarSolicitacao(CriarSolicitacaoInput input) async {
    return Solicitacao(
      id: 2,
      clienteId: input.clienteId,
      titulo: input.titulo,
      descricao: input.descricao,
      categoria: input.categoria,
      orcamento: input.orcamento,
      status: 'aberta',
      prazoEntrega: input.prazoEntrega,
    );
  }

  @override
  Future<List<Proposta>> listarPropostas(int solicitacaoId) async => [];

  @override
  Future<List<Solicitacao>> listarSolicitacoesDoCliente(int clienteId) async {
    return [_solicitacao];
  }
}
