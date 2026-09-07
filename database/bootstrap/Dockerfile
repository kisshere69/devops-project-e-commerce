FROM python:3.13.15-alpine3.24

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY alembic.ini .

COPY database/ database/

CMD ["python", "database/bootstrap/bootstrap.py"]