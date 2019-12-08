---
title: Monitorando o Raspberry
date: 2019-12-07 15:15:15
tags: raspberry, shellscript, linux
---

# Introdução

É muito comum a gente começar a usar o raspberry mas não ter muita noção de como monitorá-lo, saber o que está acontecendo com ele. Este post tem como intenção mostrar os comandos mais comuns de monitoração que o Linux oferece e mostrar como podem ser usados para ter uma visibilidade da saúde do seu hardware.

##### Aviso: aqui não vamos tratar de ferramentas de monitoração, como Zabbix e Prometheus. A ideia é criar nossa própria rotina de monitoração através da execução periódica de uma série de comandos que o Linux já oferece

##### Mais um aviso: todos os comandos deste texto devem ser executados como root. Não recomendo o sudo, pois vamos precisar rodar muitas coisas, editar arquivos, rodar de novo etc. Então é mais fácil iniciar uma sessão como root mesmo

---

# Começando a brincadeira

Aí você tá lá todo feliz, acabou de instalar o Raspbian. Vira root. Dá uns `cd` e `ls` aqui e ali, para e suspira. Fica olhando então pra tela sem a menor ideia do que fazer com aquele troço. Aí o ícone do raio começa a piscar no canto superior direito e você fica preocupado. E agora?

Antes de mais nada, vamos focar nos recursos que devemos monitorar. Esta é a minha lista, mas você pode criar a sua depois, com base nas suas necessidades mais específicas:
* atividade do "disco" — no caso, do cartão SD né hehe!
* Temperatura — item extremamente importante para preservar a vida útil do equipamento como um todo
* Tensão/voltagem — importante para saber se o Raspie entrou em *undervoltage*
* Processo que mais consome memória — devido à pouca memória, é sempre importante saber quem pode pôr tudo a perder a qualquer momento :D
* Desempenho geral da memória — monitoração de toda a atividade de memória, tanto a RAM quanto a *swap*

---

# Preparação inicial

Agora que definimos quais aspectos iremos monitorar, vamos repassar quais comandos vamos utilizar. Depois disso, vamos juntar todos eles num comandão e ver como isso vai funcionar.

Aqui, cabe um aviso a quem não tem muita afinidade com o terminal do GNU/Linux: vamos utilizar comandos simples, comandos concatenados e até um shell script. Portanto, vamos passar primeiro pelos exemplos mais simples para depois explorar os mais complexos.

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

# Botando a mão na massa

Agora que:
* já sabemos quais partes do hardware iremos monitorar
* já temos um editor de texto bão instalado

podemos começar de fato a monitorar nosso raspinho.

Vamos começar pelos mais fáceis, que exigem apenas um comando.

## Monitoração de disco e memória

Monitorar o disco e a memória exigem apenas um comando. Entretanto, vou dissecar um pouco o que cada comando mostra na tela, para entendermos a importância de cada informação.

### Monitoração de disco

Para monitorar o disco, utilizamos o comando `iostat`. Ele faz parte do pacote sysstat. Vamos instalá-lo caso ele ainda não esteja no sistema:

```
apt-get update && sudo apt-get install -yq sysstat
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
* MB_wrtn/s — é o número de gravações por segundo.
* MB_read — é o número total de leituras feitas desde o boot
* MB_wrtn — é o número total de escritas feitas desde o boot

Facinho, né? Agora vamos pro próximo comando

`EoF`
---
