# CamEditor - Editor de câmera atualizado para o open.mp

## Visão Geral
O CamEditor é um filterscript que permite criar movimentos suaves de câmera diretamente no jogo. Esta ferramenta facilita a criação de sequências cinemáticas, cutscenes e intros de servidor sem a necessidade de softwares de edição externos.

## Recursos
- **Navegação 3D Intuitiva**: Navegue facilmente pelo seu mapa usando um modo de voo avançado
- **Posicionamento com Cliques**: Defina posições da câmera com simples cliques do mouse
- **Controle Completo de Edição**: Modifique pontos iniciais, pontos finais, velocidades e rotações a qualquer momento
- **Pré-visualização em Tempo Real**: Visualize instantaneamente seus movimentos de câmera antes de salvar
- **Funcionalidade de Exportação**: Salve movimentos de câmera como trechos de código prontos para uso

## Suporte a Idiomas
O filterscript está disponível em:
- Inglês
- Português

## Instalação
1. Baixe o arquivo `cameditor.pwn`
2. Coloque-o na pasta `filterscripts` do seu servidor
3. Compile o script usando o compilador de sua preferência
4. Adicione `cameditor` ao seu arquivo de configuração JSON

## Comandos
- `/cameditor` - Ativa a ferramenta de edição de câmera
- `/closecameditor` - Sai do editor de câmera a qualquer momento

## Guia de Uso

### Criando um Movimento de Câmera
1. Digite `/cameditor` para iniciar a ferramenta
2. Use as teclas W, A, S, D (ou as teclas de movimento configuradas) para navegar no espaço 3D
3. Posicione sua câmera no ponto inicial desejado
4. Pressione a tecla de Fogo (geralmente o botão esquerdo do mouse) para definir a posição inicial
5. Navegue até onde deseja que o movimento da câmera termine
6. Pressione a tecla de Fogo novamente para definir a posição final
7. Configure as velocidades de movimento e rotação na caixa de diálogo
8. Visualize, ajuste e salve o movimento da câmera

### Opções de Edição
Após configurar um movimento de câmera, você pode:
- **Pré-visualizar**: Assista ao movimento da câmera em tempo real
- **Modificar Ponto Inicial**: Reposicione a localização inicial da câmera
- **Modificar Ponto Final**: Reposicione a localização final da câmera
- **Ajustar Velocidades**: Ajuste as durações de movimento e rotação
- **Salvar**: Exporte o movimento como trechos de código prontos para uso

## Exemplo de Saída
Quando você salva um movimento de câmera, o script gera um código como este na pasta `scriptfiles`:

```pawn
|----------MeuMovimento----------|
InterpolateCameraPos(playerid, 575.325988, -1244.656127, 25.845386, 735.324829, -1128.916870, 73.661872, 7777);
InterpolateCameraLookAt(playerid, 571.176696, -1247.412109, 26.278436, 733.528747, -1124.687866, 71.689620, 7777);
```

Basta copiar e colar este código no seu gamemode ou filterscript para movimentos de câmera perfeitos!

## Créditos
- **Drebin** - Criação original e conceito
- **itsneufox** - Atualização para compatibilidade com open.mp
- **h02** - Funcionalidade base do modo de voo

## Feedback e Suporte
Se você encontrar algum problema ou tiver sugestões de melhorias, crie uma issue neste repositório do GitHub ou entre em contato comigo através do Discord do open.mp.

---

*Nota: Esta ferramenta é projetada para desenvolvimento de servidores. O uso em servidores de produção deve ser restrito apenas a administradores.*
