---
title: Algumas dicas de Bash
date: 2019-07-01 13:14:49
tags: bash

---

### Introdução

No terminal, seja ele `bash`, `sh`, `zsh`, até mesmo no `fish` muitos se sentem perdidos por não terem tanta intimidade. E mesmo depois de algum tempo ainda não exploram tudo o que ele tem a oferecer.
Neste curtíssimo artigo vamos explorar algumas dicas de produtividade que utilizo no dia-a-dia que podem facilitar a vida de quem ainda se sente limitado pela tela preta.

---

### Entrando pelo cano

No mundo Unix, existe uma filosofia: um comando deve fazer apenas uma coisa; da melhor maneira possível. E como fazer quando precisamos de uma solução mais complexa que aquele comando não oferece? A solução é conectar comandos. Para isso, temos algumas opções, que vamos mostrar aqui bem rapidamente: o cano ou pipe simples e o duplo; os sinais de menor e maior; o "e" comercial, simples e duplo; e, por fim, o jogo-da-velha/sustenido/hashtag que eu carinhosamente chamo de "tralha": `#` - esse cara é demais e vai mudar tua vida, por isso será falado por último ; )
Suponhamos que precisamos filtrar a saída de um comando. O mais comum é:

```
comando1 | comando2
```

Neste caso, usamos o pipe para automaticamente dizer:
─ `comando2`, pegue a saída do `comando1` e faça algo com ela!

A seguir temos um exemplo bem comum de como fazer isto:
```
dmesg | grep mount
```
Basicamente rodamos o comando `dmesg`, filtrando apenas as linhas que tenham a palavra "mount".

---

### Vai pra lá, vem pra cá

Antes de começarmos a falar dos sinais de maior e menor, precisamos entender que:
no mundo Unix, TUDO são arquivos e diretórios. Mas quando eu falo tudo, é tudo MESMO! Até mesmo dispositivos de hardware como placas de som ou impressoras. Mas isso é assunto pra outro artigo. Se quiser ler mais sobre, recomendo pesquisar sobre os file systems virtuais `/proc` e `/sys`, pra começar.

Os comandos têm três canais de comunicação com o usuário: a entrada padrão; a saída padrão e a saída de erro padrão. Então, você pode enviar dados para um comando apenas por um canal, mas pode exportar por dois ; )

E é com isto que vamos brincar utilizando os sinais de maior e menor. A seguir, alguns exemplos bem comuns de como fazer isto:
```
dmesg > /tmp/relatorio_de_boot.txt
```
Neste primeiro exemplo, executamos o comando `dmesg` jogando toda a sua saída padrão para o arquivo `/tmp/relatorio_de_boot.txt`. Agora vamos conferir este aqui:
```
find / -type d > /tmp/lista_de_diretorios.txt 2> /tmp/lista_de_diretorios-erros.txt
```
Neste segundo exemplo, utilizamos o `2>` para redirecionar a saída de erro padrão para um arquivo diferente do arquivo em que estamos gerando a saída esperada do comando `find`. Isto é muito útil para filtrar os erros do que era pra ser a saída esperada do comando. Mas… E se quisermos manter o conteúdo de um arquivo? Neste caso, temos que fazer assim:
```
echo Hoje é segunda-feira >> /tmp/que_dia.txt
echo Amanhã é terça-feira >> /tmp/que_dia.txt
cat /tmp/que_dia.txt
```
Se o arquivo estiver vazio ou não existir, não tem problema usar o `>>`. Ele vai criá-lo automaticamente. E se já tiver algum conteúdo, vai adicionar a saída do comando echo ao seu final. Bem, agora que já falamos do maior e do maior-duplo, vamos falar do menor. Como eu havia dito anteriormente, um comando tem três canais de comunicação, vamos relembrar:
* entrada padrão
* saída padrão
* saída de erro padrão

Já falamos da saída padrão e da saída de erro, então só falta falarmos da entrada padrão. Para isso vamos utilizar o sinal de menor, como no exemplo abaixo:
```
comando < arquivo_entrada.txt
```
Isto é muito comum em _scripts_. Acaba sendo uma saída mais elegante que usar o pipe:
```
cat arquivo_entrada.txt | meuscript.sh
```
É o mesmo que:
```
meuscript.sh < arquivo_entrada.txt
```
Isto aqui também funciona:
```
echo ls > /tmp/comandos.txt
echo uptime >> /tmp/comandos.txt
</tmp/comandos.txt sh
```
Outra maneira comum é o `<(comando1)`, onde tratamos um arquivo gerado com a saída de um comando, como no exemplo abaixo:
```
cat <(ls) <(uptime)
```
Por último, claro que também temos o << mas neste caso ele tem uma utilidade bem diferente:
```
cat <<TERMINEAQUI > /dev/lp0
Olá, tudo bem? Resolvi te escrever uma carta mas este computador é tão antigo que nem tem um editor de textos decente. Então para quebrar o galho estou usando o comando cat e um "heredoc". Quando terminar, em vez de salvar para um arquivo, vou mandar estas poucas palavras direto para minha impressora. 
Pensando bem, caramba, acho que acabei de transformar meu computador quase numa máquina de escrever! Puxa que puxa!
TERMINEAQUI
```
O comando acima vai jogar para o comando cat tudo o que for digitado até chegar na expressão `TERMINEAQUI`. Quando terminar, vai redirecionar a saída para o arquivo `/dev/lp0`, que costuma apontar para a primeira impressora reconhecida e configurada, dependendo do Linux (ou qualquer outro sistema operacional baseado ou inspirado em Unix) que você tiver.

---

### Pausa para os comerciais
Antes de continuarmos: este texto acabou ficando meio grande demais, então vou tentar ser mais conciso nas próximas dicas, porém sem perder a essência jamais. Pegue uma água, pratique o que já aprendeu e volte mais tarde `^_^`

---

### Por baixo dos panos
A próxima dica agora é o `&`:
```
comando &
```
Este `&` ao final da linha irá fazer com que o comando rode em segundo plano, liberando o terminal para você fazer o que quiser. Quando ele terminar, irá exibir uma mensagem te informando de seu encerramento. Para retomar este comando ao primeiro plano, utilize o comando `fg`. Ele automaticamente irá retomar o comando que você dispensou.
Se você tiver digitado um comando e ele estiver demorando, você pode enviá-lo depois para o segundo plano. Para isso, basta digitar a sequência de comandos `Ctrl + Z`. Ou seja, o `Ctrl + Z` é quase como um `&` depois de já ter dado Entere iniciado o comando. Eu falei "quase" porque o `Ctrl + Z` envia o processo para o segundo plano, porém deixa ele pausado. Para que o processo de fato continue rodando em segundo plano, você precisa do comando `bg`. Então, o processo todo se dá em três passos:
Chama o comando normalmente: `comando`
* Pressiona `Ctrl + Z` para enviar o processo para o segundo plano (ele vai ser pausado)
* Digita o comando `bg` para que o processo continue rodando em segundo plano

### Dicas rápidas
#### Para listar os processos rodando em segundo plano, use o comando:
```
jobs
```
#### Para voltar para um comando específico:
```
fg %N
```
Onde `N` é o número do job que você quer mandar pro primeiro plano.
Você também pode matar o job em segundo plano. Neste caso, basta usar o `kill` da seguinte maneira:
```
kill %N
```

---

### Por onde for, quero ser seu par
Imagine que você só quer rodar um determinado comando se o resultado de um comando anterior funcionar. É aí que entra o e-comercial duplo:
```
ls /etc/shadow && echo ALL YOUR PASSWORDS ARE BELONG TO US
```

### Se você não for, só você não vai
Vamos agora fazer o contrário: um comando só vai rodar se o comando anterior falhar. Conheça o cano duplo:
```
false || echo YOU ARE FAKE NEWS
```

---

### Ela partiu, partiu e nunca mais voltou
Tanto para o `&&` quanto para o `||` é comum filtrarmos a saída padrão ou até mesmo a saída de erro padrão. Lembra que lá em cima eu falei que TUDO no mundo Unix eram arquivos e diretórios (pastas)? Pois bem, existe um arquivo só para onde você pode jogar tudo aquilo que não quiser ver: conheça o `/dev/null`
Quando a gente quiser jogar uma saída fora, basta fazer assim:
```
echo EU FALO FALO FALO MAS VOCE NUNCA ME ESCUTA > /dev/null
```
Agora, vamos juntar com o uso do `&&`:
```
ls / > /dev/null && echo Tudo tranquilo e favoravel
```
Mas caso queiramos que os erros não apareçam, então faremos assim:
```
cat / 2> /dev/null || echo O forninho caiu
```
No exemplo acima, tentamos ler um diretório com o comando cat, mas ele só serve para ler arquivos. Então ele vai falhar miseravelmente. A gente usou o `2> /dev/null` para filtrar este erro.
Experimente executar o comando sem o `2> /dev/null` para ver no que dá:
```
cat /
```
### Chegou a hora
Se você aguentou até aqui, meus parabéns! #WeAreTheChampions
Agora vamos falar da tralha/cerquilha/sustenido/_hashtag_. E vai ser bem rápido, prometo `^_^#`
Quando escrevemos um _shell script_, é muito comum iniciarmos algumas linhas com este tão nobre caractere. Ele é utilizado para "comentar" uma linha. Ou seja: linhas que começam com `#` não são interpretadas como comandos. Seria o equivalente a `//` ou `REM` ou `/*` em outras linguagens.

Pois a dica agora é: às vezes você precisa executar vários comandos de uma vez. Para não precisar ficar decorando o que fazer toda vez, basta colocar um comentário ao final, como no exemplo abaixo:
```
systemctl stop bumblebeed ; systemctl stop docker ; microk8s.stop # para tudo
```
Veja que eu executei três comandos, todos separados por ponto-e-vírgula, terminando a linha com `"# para tudo"`  -- o ponto-e-vírgula é uma maneira de se executar vários comandos em uma mesma linha, sem precisar dar `Enter`.

Isto significa que eu criei um comentário pra esse tanto de coisa que eu rodei aí, e quando for procurar no histórico, posso procurar por `para tudo`. Não vou mais perder tempo e cabelos procurando por comandos obscuros que mal sei pra que servem. Opa! Acho que isso daria uma ótima pauta para um texto futuro: "comandos obscuros do Linux", anotei aqui.
Mas enfim, voltando ao assunto…

Para procurar no histórico de comandos, temos várias maneiras. As mais comuns são:
* pressionar `Ctrl + R` e começar a digitar o comando que queremos - como geramos um comentário, não precisamos mais nos preocupar com os comandos digitados: vamos pesquisar apenas pela descrição que criamos para este conjunto de comandos, que é o comentário para tudo
* utilizar o comando `history`, como no exemplo abaixo:
```
history | grep "para tudo"
```
Bem mais fácil, né? Agora, note que ao rodar o comando `history` ele retorna um número logo no início de cada linha. Você também pode fazer assim:
```
!N
```
Onde `N` seria o número da linha correspondente ao comando que você quer rodar. E por hoje é só isso mesmo, viu? `^_^#`

`EOF`
---

