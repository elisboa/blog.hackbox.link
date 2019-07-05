---
title: Escrevendo shell scripts melhores
date: 2019-07-04 20:01:20
tags: bash
---

# Introdução

Muitos desenvolvedores profissionais têm preconceito ao se depararem com um _shell script_. E com razão: _sysadmins_ não têm experiência com boas práticas de desenvolvimento de software. É muito comum ver alguém criar uma bela gambiarra para quebrar um galho que nunca é resolvido de verdade. E como é feito na pressa, acaba ficando mais feio ainda!

Claro que nem todo _shell script_ é assim. Tem projetos que nascem como _scripts_, mas como "infelizmente" são escritos por administradores de sistemas, nem sempre acabam sendo sequer legíveis. E os desenvolvedores de outras linguagens de programação, ao ver os códigos, ficam mais perdidos do que cachorro em dia de mudança — ainda que _shell scripts_ sejam basicamente um amontoado de comandos - e é aí que mora o problema.

# Pondo a mão na masssa

Agora chega de tanto falar e vamos a algumas boas práticas que podem ajudar na manutenção de um _shell script_ — note que estas dicas servem pra qualquer iniciante em qualquer linguagem de programação, mas enfim…

Um bom código é aquele que sequer precisa de comentários, de tão compreensível que é. Isto não significa necessariamente que comentários sejam desnecessários — muito pelo contrário — , mas que os comentários devam ser mais objetivos e indispensáveis.

O primeiro passo ao se escrever um _shell script_ — na verdade qualquer programa — é definir muito bem seu papel. A partir daí, podemos escrever mais facilmente, o que consequentemente irá facilitar também sua manutenção.

Uma vez que o objetivo tenha sido definido, bem documentado e tudo mais, podemos dividir as diversas partes/fases do _script_ em funções, para facilitar ainda mais a leitura.

Em _shell_, criamos funções assim:
```
function MinhaFuncaoQuerida() {
    echo estou comecando a funcao bem aqui
    comando1
    comando2
}
```
Ao criar uma função, ela não é executada imediatamente. Para que ela seja de fato executada, é necessário chamá-la no _script_. PORÉM ela deve ser chamada APÓS sua declaração. Então,
1. Declaramos a função (como no exemplo acima)
2. Chamamo-la ao final do arquivo do _script_.

Veja o exemplo abaixo:
```
#!/bin/bash -x
function PegaData() {
    PEGADATA="$(date +%Y-%M-%D)"
}
PegaData
echo -e "A data de hoje e ${PEGADATA}"
```

Neste exemplo, nós:
1. Declaramos uma função
2. Colocamos um comando nela, cuja saída é atribuída a uma variável
3. Chamamos esta função (que não dá retorno nenhum, apenas atribui o resultado de um comando a uma variável)
4. Chamamos o comando echo, exibindo o valor da variável `$PEGADATA`

As funções também podem:

- receber argumentos
- chamar outras funções
- chamar a si mesmas (para quem ainda não conhece, o termo para isto é: recursividade)

Note que a função acaba sendo chamada como se fosse um comando mesmo.

Uma coisa legal que podemos fazer com funções e que é bom para praticar é criar um arquivo de funções onde criamos todas aquelas que vão nos facilitar em alguma coisa. Foi assim que nasceram as maravilhosas funcoeszz do Grande Aurélio, eras atrás `: D`

Vamos brincar com algo bem mais simples mas que pode ser útil no nosso dia-a-dia. Crie um arquivo chamado `funcoes.sh` — não precisa dar permissão de execução nele! `; )`

Neste arquivo vamos criar uma função chamada `vaitentando`:
```
function vaitentando() {
    until $@
    do
        sleep 1
        echo -e "Tentando novamente rodar o comando $1"
    done
}
```

Basicamente, esta função tenta rodar o argumento passado — representando com `$@` — até conseguir. Ou seja: o comando `until` significa “até que seja verdade”. Se você coloca apenas um comando à frente dele sem especificar nenhuma condição, ele vai entender que se o comando rodar com sucesso, ele retornará “verdadeiro”. Aí, ele sai deste _loop_.

Para chamar esta função, vamos precisar de dois passos:
1. Importar nosso arquivo de funções através do comando `source`
2. Rodar a função que criamos, passando um parâmetro para ela:
```
source funcoes.sh
vaitentando ssh usuario@servidor
```

*PARA CASA: além do comando `source` também podemos tentar o `.` — você saberia dizer a diferença entre eles?*

Nossa função vai ficar tentando se conectar ao servidor via SSH até conseguir.

Mas… e se a gente quiser que um determinado comando fique rodando eternamente, mesmo depois que ele terminar? Sim, queremos um _loop_ infinito porque… sim! Porque é divertido! Porque… nós podemos! `: D`

Vamos adicionar uma nova função ao nosso arquivo de funções:
```
function sempredmesg() {
    while true
    do
        dmesg
	echo Pressione Control + C para cancelar este loop infinito
        sleep 1
    done
}
```

Novamente temos que fazer o `source`, para assim atualizar nossa memória com a nova função criada. Então, chamaremos a nova função — note que desta vez não estamos passando nenhum parâmetro para ela:
```
source funcoes.sh
sempredmesg
```

Para sair desta função, basta pressionar a sequência de teclas `Ctrl + C`.

# _Aliasando_

As funções são muito poderosas para armazenar um bloco de comandos e executá-los de uma vez. Podemos realizar testes condicionais com `if` e `case` também, por que não? Mas… e quando a gente quer só facilitar a execução de um único comando?

Sempre tem aquele comando grandão com uma série de parâmetros que precisamos executar e nem sempre queremos decorar tudo. No _post_ anterior vimos que é possível adicionar o `#` ao final do comando e inserir um comentário para o comando. Mas tem um cara que não falamos lá, que é o `alias`. Ele nada mais faz do que simplificar um comando chamado com diversos parâmetros, e inclusive tem vários no seu terminal bem agora. Digite apenas o comando `alias` e dê `Enter` para ver o tanto de _aliases_ que seu sistema já tem.

Note que o comando `ls`, por exemplo, contém diversos _aliases_ como:
- `l`
- `la`
- `ll`
- `lsa`

O próprio `ls` também costuma ser um `alias`, geralmente com um conteúdo como `ls --color=tty`. Ou seja, só de chamar o `ls` padrão, ele sempre vai entender que vai chamar o `ls` e também adicionar o parâmetro `--color=tty`.

Para definir um novo _alias_, basta fazer assim:

`alias meucomando='comando -parametro1 opcao1 -parametro2 opcao2'`

Os parâmetros e opções são obviamente opcionais, mas o sinal de `=` tem que ser obrigatoriamente junto do _alias_ `meucomando` seguido do valor desejado.

Agora pense nos comandos que você sempre digita passando algum parâmetro específico e crie _aliases_ para eles, colocando também no seu arquivo `funcoes.sh`. Agora você já tem seu arquivo customizado para turbinar seu terminal ainda mais. Você vai notar que vai ser muito mais fácil realizar operações mais complexas no terminal, reduzindo-as a _aliases_ ou agrupando comandos em funções. Lembre-se sempre: se você faz uma coisa várias vezes, você pode estar perdendo tempo `; )`
`EOF`
---


