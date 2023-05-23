FROM alpine

RUN apk update && \
    apk upgrade && \
    apk add git rsync

# Install Git LFS
RUN apk add curl && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.alpine.sh | sh && apk add git-lfs


ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
