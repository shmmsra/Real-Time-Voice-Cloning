FROM python:buster

RUN apt update \
    && apt install -qy less man pulseaudio alsa-utils ffmpeg rsync vim-tiny strace libportaudio2 libxcb-* libxkbcommon-x11-0 \
    && ln -s /usr/lib/x86_64-linux-gnu/libxcb-util.so.0 /usr/lib/x86_64-linux-gnu/libxcb-util.so.1
COPY ./pulseaudio/. /etc/pulseaudio/

ENV HOME=/home/dev DISPLAY=host.docker.internal:0 PULSE_SERVER=host.docker.internal QT_DEBUG_PLUGINS=1
RUN useradd --create-home --home-dir $HOME dev && usermod -aG audio,pulse,pulse-access dev && chown -R dev:dev $HOME

USER dev
RUN cd $HOME \
    && git clone https://github.com/shmmsra/Real-Time-Voice-Cloning.git
WORKDIR /home/dev/Real-Time-Voice-Cloning

RUN pip3 install torch==1.8.1+cpu torchvision==0.9.1+cpu torchaudio==0.8.1 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html \
    && mkdir -p $HOME/tmp/pretrained \
    && wget https://github.com/blue-fish/Real-Time-Voice-Cloning/releases/download/v1.0/pretrained.zip -O $HOME/tmp/pretrained.zip \
    && unzip $HOME/tmp/pretrained.zip -d $HOME/tmp/pretrained \
    && rsync -a $HOME/tmp/pretrained/ . \
    && pip3 install -r requirements.txt

CMD python3 demo_toolbox.py
