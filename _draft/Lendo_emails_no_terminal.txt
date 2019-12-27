E aí, já pensou em deixar sua vida mais produtiva e deixar seu mouse de lado pelo menos um pouco? Que tal usarmos um gerenciador de emails via terminal?

Vamos utilizar uma série de ferramentas ao migrarmos para o modo CLI, ou seja, o terminal. Hoje iniciaremos com o gerenciador de emails Mutt.

Você ainda não conhece o mutt? Nacredito! Mas fique calmo ou calma e leia este fantástico manual: http://www.mutt.org/doc/manual

Tá, mas e agora, como fazer essa bagaça funcionar? É fácil! Quase tão simples como voar! Então, vamos lá!

Primeiro, instalamos o mutt:

No Debian e derivados (como Ubuntu, Mint etc):

sudo apt install -y mutt

No Redhat e derivados (como CentOS e Fedora):

sudo yum install -y mutt

Após instalado, chegou a hora de configurá-lo. A princípio, ele cria automaticamente em seu $HOME o arquivo .muttrc. Caso não tenha criado, utilize este comando:

touch ~/.muttrc

Seguem algumas configurações básicas:

set editor=vim # Aqui setamos nosso editor de preferência

set signature= # Aqui colocaremos a assinatura caso precisamos

set from="meuemail@gmail.com"
set realname="Meu nome"

# OBS: abaixo temos a configuração do IMAP. O foco aqui não é explicar como ativar isso. Veja o manual do seu provedor de e-mail para instruções de como habilitar e utilizar o IMAP.

set imap_user="meuemail@gmail.com" #seu email
set imap_pass="pass" # falaremos mais abaixo sobre a senha para o GMail
set smtp_url="smtp://meuemail@gmail.com@smtp.gmail.com:587/" # configuração do SMTP do gmail.
set smtp_pass="pass"

set ssl_starttls=yes # Habilitar criptografia para se comunicar com o servidor de e-mail
set ssl_force_tls=yes # Forçar o uso de criptografia (senão, ele tenta se conectar sem criptografia ao falhar a conexão utilizando criptografia)

set folder="imaps://imap.gmail.com:993" # configuração de IMAP do GMail
set spoolfile="+INBOX" # no caso estamos personalizando a nossa caixa de entrada
set timeout=10 # muito importante, pois definimos de quantos em quantos minutos ele vai checar se teremos novos e-mails

# Segue abaixo uma perfumaria opcional
# Cores
color normal     white black
color attachment brightyellow black
color hdrdefault cyan black
color indicator  black cyan
color markers    brightred black
color quoted     green black
color signature  cyan black
color status     brightgreen blue
color tilde      blue black
color tree       red black
color sidebar_new yellow default
color index     yellow         default  ~N      # New
color index     yellow         default  ~O      # Old
color header    yellow         default  "^from"
color header    brightgreen    default  "^from:"
color header    green      default  "^to:"
color header    green      default  "^cc:"
color header    green      default  "^date:"
color header    yellow     default  "^newsgroups:"
color header    yellow     default  "^reply-to:"
color header    brightcyan default  "^subject:"
color header    red        default  "^x-spam-rule:"
color header    yellow     default  "^x-mailer:"
color header    yellow     default  "^message-id:"
color header    yellow     default  "^Organization:"
color header    yellow     default  "^Organisation:"
color header    yellow     default  "^User-Agent:"
color header    yellow     default  "^message-id: .*pine"
color header    yellow     default  "^X-Fnord:"
color header    yellow     default  "^X-WebTV-Stationery:"
color header    yellow     default  "^X-Message-Flag:"
color header    yellow     default  "^X-Spam-Status:"
color header    yellow     default  "^X-SpamProbe:"
color header    red        default  "^X-SpamProbe: SPAM"
color body      yellow     default  "[;:]-[)/(|]"  # colorise smileys

# Sobre a senha:

Para configurar o GMail no mutt, a senha utilizada no seu e-mail via acesso web normalmente não funciona, pois o Google não conhece o mutt e bloqueia seu uso. A solução para isso é:

Acesse, via webmail, sua conta e vá em:

Gerenciar sua conta → segurança → Signing in to Google → app password:

Em select app clique em “mail” em select device “other”

Feito isso, ele vai gerar uma senha para você. Sua senha para acesso via webmail continuará a mesma. Guarde essa senha gerada, volte às configurações do mutt e no campo pass coloque ela. Rode o mutt e POW!!! Você está agora recebendo e enviando e-mails pelo terminal.



--- esta parte será um artigo a parte

BONUS!!!:

Que tal após receber e enviar e-mail pelo terminal, agora sermos notificados quando chegarem novos emails?

Para isso, vamos instalar o notify-send

No 

  sudo apt install libnotify-bin

Familia Redhat:

  sudo yum install libnotify-bin # faz um tempo que não uso família Redhat se não for assim me desculpe :(

após instalação vamos incluir dentro da config .muttrc a seguinte linha:


set new_mail_command="notify-send 'Titulo' 'Mensagem'" e já era!!

caso queira conhecer mais parametro do notify-send segue: https://ss64.com/bash/notify-send.html
