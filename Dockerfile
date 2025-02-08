# Usando uma imagem base menor para otimizar o tamanho final
FROM jupyter/minimal-notebook:python-3.7.6  

# Mudando para root para instalação de pacotes
USER root  

# Atualiza pacotes e instala dependências essenciais
RUN apt-get update && apt-get install -y \
    dbus-x11 \
    firefox \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Definição da versão do TurboVNC
ARG TURBOVNC_VERSION=2.2.6  

# Instalando TurboVNC de forma mais confiável
RUN wget -q "https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download" -O turbovnc.deb && \
    apt-get install -y ./turbovnc.deb && \
    apt-get remove -y light-locker && \
    rm -f turbovnc.deb && \
    ln -s /opt/TurboVNC/bin/* /usr/local/bin/

# Garantindo permissões corretas na pasta do usuário
RUN chown -R $NB_UID:$NB_GID $HOME  

# Adicionando arquivos ao container
ADD . /opt/install  
RUN fix-permissions /opt/install  

# Mudando para usuário não root
USER $NB_USER  

# Atualizando ambiente Conda sem cache para evitar conflitos
RUN cd /opt/install && \
    conda env update -n base --file environment.yml && \
    conda clean --all -f -y

