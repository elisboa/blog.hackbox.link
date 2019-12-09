---
title: Monitorando o Raspberry
date: 2019-12-07 15:15:15
tags: raspberry, shellscript, linux
---

# Monitorando o Raspberry

## Introdução

É muito comum a gente começar a usar o Raspberry Pi sem ter muita noção de como monitorá-lo, saber o que realmente está acontecendo com ele. Este humilde *post* tem como intenção mostrar os comandos mais comuns de monitoração que o Linux oferece e mostrar como podem ser usados para ter uma visibilidade da saúde do seu hardware.

**Aviso: aqui não vamos tratar de ferramentas de monitoração, como Zabbix e Prometheus. A ideia é criar nossa própria rotina de monitoração através da execução periódica de uma série de comandos que o Linux já oferece**

**Mais um aviso: todos os comandos deste texto devem ser executados como root. Não recomendo o sudo, pois vamos precisar rodar muitas coisas, editar arquivos, rodar de novo etc. Então é mais fácil iniciar uma sessão como root mesmo**

## Começando a brincadeira

Aí você tá lá todo feliz, acabou de instalar o Raspbian. Vira root. Dá uns `cd` e `ls` aqui e ali, para e suspira. Fica olhando então pra tela sem a menor ideia do que fazer com aquele troço. Aí o ícone do raio começa a piscar no canto superior direito e você fica preocupado. E agora?

Antes de mais nada, vamos focar nos recursos que devemos monitorar. Esta é a minha lista, mas você pode criar a sua depois, com base nas suas necessidades mais específicas:
* atividade do "disco" — no caso, do cartão SD né hehe!
* Temperatura — item extremamente importante para preservar a vida útil do equipamento como um todo
* Tensão/voltagem — importante para saber se o Raspie entrou em *undervoltage*
* Processo que mais consome memória — devido à pouca memória, é sempre importante saber quem pode pôr tudo a perder a qualquer momento :D
* Desempenho geral da memória — monitoração de toda a atividade de memória, tanto a RAM quanto a *swap*

## Preparação inicial

Agora que definimos quais aspectos iremos monitorar, vamos repassar quais comandos vamos utilizar. Depois disso, vamos juntar todos eles num comandão e ver como isso vai funcionar.

Aqui, cabe um aviso a quem não tem muita afinidade com o terminal do GNU/Linux: vamos utilizar comandos simples, comandos concatenados e até um *shell script*. Portanto, vamos passar primeiro pelos exemplos mais simples para depois explorar os mais complexos.

Antes de começarmos, sugiro instalar um editor de textos. Você pode utilizar o nano:
```
apt-get update && apt-get install -yq nano
```

ou pode partir pro vim:

```
apt-get update && apt-get install -yq vim
```

Em quaisquer dos casos, vou deixar manuais bem básicos aqui para você conseguir se virar com o básico ao utilizar cada um deles:

* [Manual básico do Nano](https://www.vivaolinux.com.br/artigo/Introducao-ao-Linux-O-editor-de-texto-Nano)
* [Manual básico do Vim](https://www.vivaolinux.com.br/artigo/Guia-rapido-VI)

## Utilizando comandos básicos

Agora que:
* já sabemos quais partes do hardware iremos monitorar
* já temos um editor de texto bão instalado

podemos começar de fato a monitorar nosso raspinho.

Vamos começar pelos mais fáceis, que exigem apenas um comando.

### Monitoração de disco e memória

Monitorar o disco e a memória exigem apenas um comando. Entretanto, vou dissecar um pouco o que cada comando mostra na tela, para entendermos a importância de cada informação.

#### Monitoração de disco

Para monitorar o disco, utilizamos o comando `iostat`. Ele faz parte do pacote sysstat. Vamos instalá-lo caso ele ainda não esteja no sistema:

```
apt-get update && apt-get install -yq sysstat
```

Agora, basta rodar o comando:
```
root@raspberrypi:~# iostat
Linux 4.14.98-v7+ (raspberrypi)         12/08/19        _armv7l_        (4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.07    0.00    1.82    0.01    0.00   97.10

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
loop0             0.02         0.03         0.00      13921          0
loop1             0.02         0.02         0.00      12415          0
loop2             0.02         0.02         0.00      10540          0
loop3             0.00         0.00         0.00          4          0
mmcblk0           0.81         0.66        15.02     357760    8178777
```

Note que ele mostra uns dispositivos de *loop* ali, e lá embaixo o tal `mmcblk0`, que é o único que contém atividades de escrita e de leitura.

Não vou entrar no detalhe do que é e pra que serve um dispositivo de *loop* aqui, mas [fique com este artigo](https://pt.wikipedia.org/wiki/Loop_device) para se informar mais caso tenha interesse.

A verdade é que tem muita coisa ali. Mas só temos um cartão. Vamos por enquanto ignorar estes *loops* para filtrar melhor nossa saída:
```
root@raspberrypi:~# iostat -d mmcblk0
Linux 4.14.98-v7+ (raspberrypi)         12/08/19        _armv7l_        (4 CPU)

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
mmcblk0           0.81         0.66        15.04     357772    8202325
```

Bem melhor, né?

Para deixar um pouco mais legivel, acho que podemos mudar só mais uma coisa: exibir as quantidades em megas em vez de kilos:

```
root@raspberrypi:~# iostat -d mmcblk0 -m
Linux 4.14.98-v7+ (raspberrypi)         12/08/19        _armv7l_        (4 CPU)

Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
mmcblk0           0.81         0.00         0.01        349       8011
```

Agora sim, já temos nossa monitoração de disco. Mas antes de ir para o próximo passo, vamos revisar rapidamente as métricas que estamos monitorando:
* tps — *transfers per second*, ou seja: transferências por segundo. Em resumo, é o número de requisições de transferência feitas pelo sistema operacional. Podem ser tanto para escrever quanto para ler. O tamanho delas não é considerado aqui
* MB_read/s — é o número de leituras por segundo. Cada leitura compreende um bloco de 512 bytes
* MB_wrtn/s — é o número de gravações por segundo
* MB_read — é o número total de leituras feitas desde o boot
* MB_wrtn — é o número total de escritas feitas desde o boot

Facinho, né? Agora vamos pro próximo comando.

#### Monitoração de memória

Vamos utilizar o comando `vmstat` para monitorar a memória do sistema. Ele está presente no pacote procps. Se o comando ainda não estiver disponível no terminal, instale agora:

```
sudo apt-get update && apt-get install -yq procps
```

Assim como o iostat, o vmstat também é bem simples de se utilizar:

```
root@raspberrypi:~# vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 3  0    256 131720  94376 683096    0    0     0     4    9   13  1  2 97  0  0
```

Agora, vamos utilizar alguns parâmetros para tornar a visualização um pouco melhor (ou não!):

```
root@raspberrypi:~# vmstat -Sm -w
procs -----------------------memory---------------------- ---swap-- -----io---- -system-- --------cpu--------
 r  b         swpd         free         buff        cache   si   so    bi    bo   in   cs  us  sy  id  wa  st
 1  0            0          132           97          701    0    0     0     4    9   13   1   2  97   0   0
```

O `-w` deixou a visualização mais larga. Pode desconsiderá-lo se não tiver ficado bom para você.

O `-S` serve para escolhermos o tipo de unidade a ser medida e o `m` logo após diz que queremos megas.

Note que além da memória RAM, ele também exibe informações sobre a memória SWAP, entrada e saída (o famoso I/O), atividade do sistema e, por último, CPU.

Vamos passar rapidamente pelos detalhes de cada um:

* procs
  * r — número de processos em execução (rodando ou prontos para rodar)
  * b — número de processos dormindo
* memory
  * swpd — quantidade de memória virtual utilizada
  * free — quantidade de memória física disponível
  * buff — memória utilizada como buffer (discos, placas de som, rede, teclados e todos os outros equipamentos utilizam este tipo de memória durante suas atividades)
  * cache — esta é a memória com conteúdo utilizado constantemente, para ser mais rapidamente reaproveitado
* swap
  * si — quantidade de memória virtual lida a partir do(s) disco(s) por segundo
  * so — quantidade de memória virtual escrita no(s) disco(s) por segundo
* io
  * bi — quantidade de blocos recebidos de um dispositivo por segundo
  * bo — quantidade de blocos enviados para um dispositivo por segundo
* system
  * in — número de interrupções por segundo
  * cs — número de trocas de contexto por segundo
* cpu (valores expressos em porcentagem do tempo total de CPU: 100%)
  * us — tempo gasto executando qualquer código que não seja parte do núcleo do sistema operacional, como aplicativos, interação com o usuário etc (*user time*)
  * sy — tempo gasto executando código relacionado ao kernel ou seus módulos (*system time*)
  * id — tempo ocioso, sem fazer nada, esperando tarefas
  * wa — tempo gasto aguardando atividades de entrada e saída (I/O), como quando o CPU aguarda uma escrita de arquivos em disco
  * st — tempo "roubado" de uma máquina virtual, quanto maior, pior. Simplificando muito, se duas máquinas virtuais estiverem dividindo o mesmo hardware, uma sempre irá roubar o tempo da outra. Então, se esta métrica estiver muito alta, você provavelmente terá nas mãos um sistema muito lento. Mas como estamos falando de raspberry, podemos desconsiderar isto por enquanto (eu acho)

Como você pode notar, o vmstat mostra mais que simplesmente informações de memória. É uma ferramenta poderosa para ter um bom olhar sobre diversos aspectos do seu equipamento. Mas ainda tem mais. Vamos continuar…

## Comandos concatenados

As informações que vamos coletar agora dependem da execução de mais de um comando ao mesmo tempo. Esta é a segunda fase do nosso monitoramento. Para isso, vamos utilizar o *pipe*, representado pelo caractere `|`. Este cara vai nos permitir pegar a saída de um comando e utilizá-la como entrada para outro. Geralmente isto é feito quando o `comando1` gera muita informação e precisamos filtrar apenas o que realmente queremos, utilizando o `comando2`.

Agora chega de papo e vamos ao que interessa!

### Filtrando a variação de tensão/voltagem

O GNU/Linux tem um comando que sempre informa as mensagens geradas pelos *drivers* de dispositivos desde o último *boot*. Este comando se chama `dmesg`. Ele é quem vai nos dizer quando e se houve alguma variação na tensão da corrente, assim como nos informar se ela se estabilizou ou não.

Acontece que o `dmesg`, ao ser executado, sempre vai mostrar tudo o que aconteceu desde o começo do *boot*. Mas só queremos o último estado da variação da tensão. Para isto, usaremos um "filtro", pegando sua saída e tirando apenas o que nos interessa de fato.

Aqui em casa fiz da seguinte maneira:

```
root@raspberrypi:~# dmesg | grep -i voltage | tail -n1
root@raspberrypi:~#
```

Explicando bem rapidamente:
* `dmesg` — mostra um histórico de mensagens de todos os drivers, desde o momento do boot
* `grep` — comando que filtra a saída do comando anterior
  * `-i` — ignora a diferença entre maiúsculas e minúsculas
  * `voltage` — é o termo que estamos buscando
* `tail` — comando utilizando para mostrar as últimas dez linhas de um arquivo ou texto
  * `-n1` — faz o `tail` mostrar apenas a última linha

### Mostrando o processo que consome mais memória

Como os Raspberries 2 e o 3 tem apenas 1GB de RAM, é importante saber quem está consumindo mais memória. Para isso, vamos utilizar essa sequência de comandos:

```
root@raspberrypi:~# ps aux --sort=-%mem | head -n2
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root     23999  0.3  1.6  49956 16888 ?        S    Dec07   3:46 /usr/sbin/smbd
```

Temos duas maneiras de comprovar se este comando está funcionando mesmo:

1. rodar um outro comando que consuma mais memória e, em outro terminal, rodar novamente este `ps`.
2. abrir, em outro terminal, o comando `htop`, pressionar Shift + M e verificar qual o comando com maior consumo de memória por lá e ver se bate com nosso `ps`.

Partindo do princípio que está tudo certo, vamos então dissecar o que essa sequência faz:

* `ps` — mostra a lista de processos (em execução ou em espera) no sistema
  * `a` — mostra todos os processos (de outros terminais e de outros usuários)
  * `u` — mostra o dono de cada processo
  * `x` — exibe os processos que não estão associados a um terminal (como daemons ou chamadas ao núcleo)
  * `--sort=%mem` — organiza por ordem de consumo de memória
* `head` — comando utilizado para mostrar as primeiras dez linhas de um arquivo ou texto
  * `-n2` — faz o `head` mostrar apenas as duas primeiras linhas

## Monitorando a temperatura

Agora vem a parte mais "complexa", que é escrever um script para podermos monitorar a temperatura do equipamento. Como vamos querer comprovar o funcionamento correto do nosso script, é interessante termos algumas ferramentas que nos ajude a causar a variação de temperatura que queremos. São elas:

1. O pacote stress `apt-get update && apt-get install stress -yq`.
2. Um ventilador.

Agora que temos tudo preparado, pegue o seu editor preferido e insira nele o seguinte conteúdo:
```
#!/bin/bash

cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
cpuTemp1=$(($cpuTemp0/1000))
cpuTemp2=$(($cpuTemp0/100))
cpuTempM=$(($cpuTemp2 % $cpuTemp1))

echo CPU temp"="$cpuTemp1"."$cpuTempM"'C"
```

Após inserir o conteúdo acima, saia salvando e dê permissão de execução ao seu arquivo:

`chmod a+x temp.sh`

Vamos rodar e ver o que acontece?

```
root@raspberrypi:~# ./temp.sh
CPU temp=51.3'C
```
É, parece que deu certo!

Agora, vamos fazer um teste de estresse e ver se a temperatura subiu:

```
root@raspberrypi:/# echo temperatura antes ; ./temp.sh ; echo ;  stress --vm 2 --vm-bytes 320M --timeout 180s --cpu 16 --io 4 -d 32 ; echo ; echo temperatura depois ; ./temp.sh
temperatura antes
CPU temp=50.8'C

stress: info: [830] dispatching hogs: 16 cpu, 4 io, 2 vm, 32 hdd
stress: info: [830] successful run completed in 185s

temperatura depois
CPU temp=61.6'C
```

É, parece que cozinhou legal. Agora vamos pegar o ventilador e ver se registramos a queda de temperatura:

```
root@raspberrypi:/# echo temperatura antes ; ./temp.sh ; sleep 300  ; echo ; echo temperatura depois ; ./temp.sh
temperatura antes
CPU temp=57.3'C

temperatura depois
CPU temp=49.2'C
```

Após cinco minutinhos, vemos que a temperatura baixou. Talvez precisemos de um ventilador mais potente, mas já deu pra notar a diferença. Podemos dizer que nosso script de monitoração está mesmo funcionando.

Vamos agora copiar este script para um local mais apropriado. No meu raspberry, costumo colocar meus scripts em /usr/local/sbin:

`mv temp.sh /usr/local/sbin`

## Juntando tudo

Agora vamos juntar todos os comandos que utilizamos em um só, porém com algumas modificações para que fique tudo mais legível:

```
while true ; do clear ; iostat -d mmcblk0 -m ; echo ; vmstat -Sm ; echo ; /usr/local/sbin/temp.sh ; echo -n 'Last Undervoltage Message: ' ; dmesg | grep -i voltage | tail -n1 ; echo -e "\n" ; echo 'Most memory consuming proccess: ' ; ps aux --sort=-%mem | head -n2 ; echo ; dmesg | tac | egrep -vi voltage | head -n 15 ; sleep 3 ; done
```

Tudo isso aí é uma linha só! Garrancheira danada, mas que vai funcionar!

Vamos ver como fica nossa monitoração?

```
Linux 4.14.98-v7+ (raspberrypi)         12/08/19        _armv7l_        (4 CPU)

Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
mmcblk0           1.07         0.00         0.03       2346      16899


procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  0      0    794     19    120    0    0     1     7    5    4  1  2 97  0  0

CPU temp=45.4'C
Last Undervoltage Message:

Most memory consuming proccess:
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
pi        5969  0.1  1.6  43804 16544 ?        S    15:10   0:06 /usr/sbin/smbd

[573470.764765] Adding 1023996k swap on /var/swap-02.  Priority:-3 extents:14 across:3284988k SSFS
[573461.252117] Adding 1023996k swap on /var/swap-01.  Priority:-2 extents:8 across:1417212k SSFS
[573177.054880] oom_reaper: reaped process 15420 (stress), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[573176.947260] Killed process 15420 (stress) total-vm:330008kB, anon-rss:313612kB, file-rss:0kB, shmem-rss:0kB
[573176.947236] Out of memory: Kill process 15420 (stress) score 276 or sacrifice child
[573176.947230] [15431]     0 15431     1185      225       6       0        4             0 watch
[573176.947221] [15430]  1000 15430      866       15       6       0        0             0 sleep
[573176.947211] [15425]  1000 15425      866       15       6       0        0             0 sleep
[573176.947201] [15421]     0 15421    82502    73850     150       0        0             0 stress
[573176.947192] [15420]     0 15420    82502    78403     159       0        0             0 stress
[573176.947182] [15419]     0 15419    82502    77942     158       0        0             0 stress
[573176.947173] [15418]     0 15418      581       17       5       0        0             0 stress
[573176.947164] [15412]     0 15412      866       15       6       0        0             0 sleep
[573176.947153] [12445]     0 12445     1316        2       6       0      117             0 bash
[573176.947144] [11867]     0 11867     1185      224       7       0        4             0 watch
```

Note que eu coloquei algumas mensagens utilizando o comando `echo`, além de ter adicionado também um filtro para não mostrar as variações de tensão (`gmesg | egrep -vi voltag `)ao exibir as últimas 15 mensagens do dmesg. Também coloquei uma espera de 3 segundos (`sleep 3`) para que ele repita este mesmo bloco de comandos o tempo todo. Para sair deste *loop*, basta 
pressionar Control + C.

Repare que utilizei o comando `tac`, que faz quase a mesma coisa que o `cat`, porém invertendo a ordem das linhas. Mostra as últimas primeiro. Fica mais fácil de ler os logs assim, na minha opinião. Mas você não precisa se não quiser :-)

Como rodar todos estes comandos dá uma mão de obra danada, resolvi criar um arquivo de *script* com seu conteúdo. Salvei ele com o nome de [geral.sh](https://raw.githubusercontent.com/elisboa/raspscripts/master/geral.sh).

## Conclusão

Espero que tenham gostado e aprendido mais um pouco com este artigo sobre monitoração. Visite meu [repositório de scripts e comandos para o Raspberry](https://github.com/elisboa/raspscripts).

Pensou em algo que gostaria de monitorar e não está aqui? Crie uma [*issue*](https://github.com/elisboa/raspscripts/issues/new) ou um [*pull-request*](https://github.com/elisboa/raspscripts/compare) para mim que podemos inclui-lo na próxima versão!

Até a próxima e obrigado pela companhia até aqui. Nos vemos no próximo artigo, que prometo que será mais curto — assim espero!

### Agradecimentos e referências

Quero agradecer ao [JC GreenMind](https://github.com/greenmind-sec) pela indicação do [Stackedit](https://stackedit.io/), editor que usei na postagem deste artigo e gostei muito.

Também quero agradecer ao [Carlos Loyola](https://github.com/cloyol1) pela ajuda com a revisão deste texto enquanto ainda era um rascunho.


---
`EoF`
