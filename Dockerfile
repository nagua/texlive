FROM ubuntu:16.04
MAINTAINER Nicolas Riebesel <nicolas.riebesel@gmx.com>

ENV TZ=Europe/Berlin
ENV PKG="${PKG} wget tar unzip perl vim binutils"
ENV PKG="${PKG} fontconfig tzdata"
RUN apt-get -qq update \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get -qq --force-yes -y --no-install-recommends install language-pack-en \
    && dpkg-reconfigure -f noninteractive locales \
    && if [ "${PKG}" ];then apt-get -o Acquire::http::Dl-Limit=300 --force-yes -y --no-install-recommends upgrade \
    && apt-get -o Acquire::http::Dl-Limit=300 --force-yes -y --no-install-recommends install ${PKG};fi \
    && apt-get --force-yes -y --no-install-recommends install \
    && apt-get autoremove && apt-get autoclean \
    && apt-get clean \
    && rm -rf "/var/cache/apt/archives/*" "/var/lib/apt/lists/*" \
    && echo 'debconf debconf/frontend select Dialog' | debconf-set-selections

ENV TERM=xterm LANGUAGE=en_US:en LANG=en_US.UTF-8 LC_TIME=POSIX
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN mkdir -p install-tl \
    && wget -nv -O install-tl.tar.gz http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
    && tar -xzf install-tl.tar.gz -C install-tl --strip-components=1
ADD texlive2017.profile install-tl/
RUN ( cd install-tl/ \
    && ./install-tl --persistent-downloads --profile texlive2017.profile \
    || ( ./install-tl --persistent-downloads --profile texlive2017.profile \
    || ./install-tl --persistent-downloads --profile texlive2017.profile )) \
    && rm install-tl.tar.gz && rm -r install-tl
RUN cp $(kpsewhich -var-value TEXMFSYSVAR)/fonts/conf/texlive-fontconfig.conf /etc/fonts/conf.d/09-texlive.conf
RUN fc-cache -fsv
RUN echo "check_certificate = off" >> ~/.wgetrc
RUN mkdir -p install-getnonfreefonts \
    && cd install-getnonfreefonts \
    && wget -nv -O install-getnonfreefonts https://tug.org/fonts/getnonfreefonts/install-getnonfreefonts \
    && texlua install-getnonfreefonts \
    && cd .. && rm -r install-getnonfreefonts \
    && /usr/local/texlive/2017/bin/x86_64-linux/getnonfreefonts --sys -a
RUN luaotfload-tool --update
CMD /bin/bash
