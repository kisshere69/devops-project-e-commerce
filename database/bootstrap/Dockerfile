FROM python:3.13.15-alpine3.24

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt \
    && rm -rf /usr/local/lib/python3.13/site-packages/pip \
              /usr/local/lib/python3.13/site-packages/pip-*.dist-info

COPY alembic.ini .

COPY database/ database/

CMD ["python", "database/bootstrap/bootstrap.py"]