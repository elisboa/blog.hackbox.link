#Image source
from node:9.9.0

ENV BLOGDIR $HOME/git/blog.hackbox.link

#ADD deploy.sh
COPY . $BLOGDIR
RUN chmod a+x deploy.sh
ENTRYPOINT ./deploy.sh

