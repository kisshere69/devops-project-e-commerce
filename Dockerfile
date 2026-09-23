FROM python:3.13.15-alpine3.24

WORKDIR /app

RUN apk add --no-cache curl

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]