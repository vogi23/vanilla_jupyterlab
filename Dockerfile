FROM vogi23/python36-jupyterlab:1.0.0

LABEL maintainer="Christian von Gunten <chrigu@vgbau.ch>"

ENV MAIN_PATH=/project

RUN pip install -r ./requirements.txt

EXPOSE 8888

ENTRYPOINT ["/bin/bash", "-c", "jupyter lab"]