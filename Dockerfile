FROM docker.io/python:3-slim-bullseye

RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade --no-install-recommends --assume-yes \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --home-dir /fig figuser
USER figuser
WORKDIR /fig

COPY requirements.txt .
COPY ./fig/backends/cloudtrail_lake/beta-sdk/* ./
RUN pip install -r ./requirements.txt
RUN pip install ./boto3-1.24.47-py3-none-any.whl ./botocore-1.27.47-py3-none-any.whl

COPY . .

CMD [ "python3", "-m" , "fig"]
