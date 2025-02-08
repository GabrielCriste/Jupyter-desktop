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

# Remover light-locker antes da instalação para evitar conflitos
RUN apt-get remove -y light-locker || true

# Instalação do TurboVNC
ARG TURBOVNC_VERSION=2.2.6
RUN wget -q "https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download" -O turbovnc.deb && \
    apt-get install -y ./turbovnc.deb && \
    rm turbovnc.deb && \
    ln -s /opt/TurboVNC/bin/* /usr/local/bin/

# Ajuste de permissões
RUN chown -R ${NB_UID}:${NB_GID} $HOME || true

# Copia os arquivos de instalação
COPY . /opt/install
RUN fix-permissions /opt/install || true

USER $NB_USER

# Atualiza o ambiente Conda, se o arquivo existir
WORKDIR /opt/install
RUN if [ -f environment.yml ]; then \
        conda env update -n base --file environment.yml; \
    else \
        echo "Arquivo environment.yml não encontrado, ignorando atualização."; \
    fi
    
