FROM jupyter/base-notebook:python-3.10

USER root

RUN apt-get update && apt-get install -y \
    dbus-x11 \
    firefox \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme \
    wget \
    && apt-get clean

# Instalação do TurboVNC
ARG TURBOVNC_VERSION=2.2.6
RUN wget -q "https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download" -O turbovnc.deb && \
    apt-get install -y ./turbovnc.deb && \
    apt-get remove -y light-locker && \
    rm turbovnc.deb && \
    ln -s /opt/TurboVNC/bin/* /usr/local/bin/

# Ajuste de permissões
RUN chown -R ${NB_UID}:${NB_GID} $HOME || true

# Copia os arquivos de instalação
ADD . /opt/install
RUN fix-permissions /opt/install || true

USER $NB_USER

# Atualiza o ambiente Conda
WORKDIR /opt/install
RUN test -f environment.yml && conda env update -n base --file environment.yml || echo "Arquivo environment.yml não 
encontrado, ignorando atualização."
