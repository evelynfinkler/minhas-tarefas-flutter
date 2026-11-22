import base64
import json
from pathlib import Path
import time
import unittest
import urllib.error
import urllib.parse
import urllib.request


BASE = 'http://127.0.0.1:19000'
PROJETO = 'demo-minhas-tarefas'


def token(uid):
    def codificar(objeto):
        return base64.urlsafe_b64encode(json.dumps(objeto).encode()).decode().rstrip('=')
    agora = int(time.time())
    dados = {
        'sub': uid, 'user_id': uid, 'aud': PROJETO,
        'iss': f'https://securetoken.google.com/{PROJETO}',
        'iat': agora, 'auth_time': agora, 'exp': agora + 3600,
        'firebase': {'sign_in_provider': 'custom', 'identities': {}}
    }
    return codificar({'alg': 'none', 'typ': 'JWT'}) + '.' + codificar(dados) + '.'


def requisicao(metodo, caminho, dados=None, uid=None, admin=False):
    query = {'ns': PROJETO}
    headers = {'Content-Type': 'application/json'}
    if admin:
        headers['Authorization'] = 'Bearer owner'
    elif uid is not None:
        query['auth'] = token(uid)
    url = f'{BASE}/{caminho}.json?{urllib.parse.urlencode(query)}'
    corpo = json.dumps(dados).encode() if metodo != 'GET' else None
    req = urllib.request.Request(url, data=corpo, headers=headers, method=metodo)
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as erro:
        return erro.code, json.load(erro)


def tarefa():
    return {'titulo': 'Estudar Flutter', 'descricao': 'Revisar os widgets',
            'dataVencimento': 1795564800000, 'prioridade': 'alta', 'concluida': False}


class RegrasDatabaseTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        regras = json.loads((Path(__file__).resolve().parents[1] / 'database.rules.json').read_text(encoding='utf-8'))
        status, resultado = requisicao('PUT', '.settings/rules', regras, admin=True)
        if status != 200:
            raise AssertionError(f'Regras recusadas pelo emulador: {resultado}')

    def setUp(self):
        status, _ = requisicao('PUT', '', None, admin=True)
        self.assertEqual(status, 200)

    def test_usuario_le_grava_edita_e_exclui_suas_tarefas(self):
        self.assertEqual(requisicao('PUT', 'tarefas/aluno/t1', tarefa(), uid='aluno')[0], 200)
        status, resultado = requisicao('GET', 'tarefas/aluno', uid='aluno')
        self.assertEqual(status, 200)
        self.assertEqual(resultado['t1']['titulo'], 'Estudar Flutter')
        self.assertEqual(requisicao('PATCH', 'tarefas/aluno/t1', {'concluida': True}, uid='aluno')[0], 200)
        self.assertTrue(requisicao('GET', 'tarefas/aluno/t1', uid='aluno')[1]['concluida'])
        self.assertEqual(requisicao('DELETE', 'tarefas/aluno/t1', uid='aluno')[0], 200)
        self.assertIsNone(requisicao('GET', 'tarefas/aluno', uid='aluno')[1])

    def test_visitante_nao_le_nem_grava(self):
        self.assertIn(requisicao('GET', 'tarefas/aluno')[0], (401, 403))
        self.assertIn(requisicao('PUT', 'tarefas/aluno/t1', tarefa())[0], (401, 403))

    def test_outra_conta_nao_le_edita_nem_exclui(self):
        requisicao('PUT', 'tarefas/aluno/t1', tarefa(), uid='aluno')
        for metodo, dados in [('GET', None), ('PUT', tarefa()), ('PATCH', {'concluida': True}), ('DELETE', None)]:
            with self.subTest(metodo=metodo):
                self.assertIn(requisicao(metodo, 'tarefas/aluno/t1', dados, uid='outra-conta')[0], (401, 403))

    def test_usuario_nao_lista_raiz_do_banco(self):
        self.assertIn(requisicao('GET', '', uid='aluno')[0], (401, 403))
        self.assertIn(requisicao('GET', 'tarefas', uid='aluno')[0], (401, 403))

    def test_rejeita_tipos_valores_e_campos_invalidos(self):
        alteracoes = [
            {'titulo': ''}, {'titulo': '   '}, {'titulo': 'x' * 101},
            {'descricao': 'x' * 2001}, {'prioridade': 'urgente'},
            {'concluida': 'sim'}, {'dataVencimento': '25/11/2026'},
            {'dataVencimento': 1795564800001}, {'dataVencimento': 1},
            {'campoExtra': 'teste'}, {'titulo': None}
        ]
        for mudanca in alteracoes:
            with self.subTest(mudanca=str(mudanca)[:100]):
                self.assertIn(requisicao('PUT', 'tarefas/aluno/t1', tarefa() | mudanca, uid='aluno')[0], (401, 403))

    def test_descricao_vazia_e_permitida(self):
        self.assertEqual(requisicao('PUT', 'tarefas/aluno/t1', tarefa() | {'descricao': ''}, uid='aluno')[0], 200)

    def test_nao_remove_campo_obrigatorio_por_atualizacao(self):
        requisicao('PUT', 'tarefas/aluno/t1', tarefa(), uid='aluno')
        self.assertIn(requisicao('PATCH', 'tarefas/aluno/t1', {'titulo': None}, uid='aluno')[0], (401, 403))

    def test_nao_substitui_lista_por_valor_simples(self):
        self.assertIn(requisicao('PUT', 'tarefas/aluno', 'invalido', uid='aluno')[0], (401, 403))


if __name__ == '__main__':
    unittest.main(verbosity=2)
