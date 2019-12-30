#Image source
from node:9.9.0

ENV BLOGDIR git/blog.hackbox.link

#ADD deploy.sh
COPY . $BLOGDIR
RUN chmod a+x $BLOGDIR/deploy.sh
ENTRYPOINT $BLOGDIR/deploy.sh

