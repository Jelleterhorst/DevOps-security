FROM python:3.12-slim-bookworm

WORKDIR /app

# Installeer poetry en zet virtual environments uit
RUN pip install poetry
RUN poetry config virtualenvs.create false

# Kopieer je configuratie vanuit de 'content' map en installeer dependencies
COPY content/pyproject.toml content/poetry.lock ./
RUN poetry lock
RUN poetry install --no-interaction --no-ansi --no-root

# Kopieer de rest van je project vanuit de 'content' map
COPY content/ .

# Maak het service account aan en geef rechten op de map (201 heb ik gedaan aangezien k3s anders neit niet zeker weet of t root is of niet)
RUN useradd -u 201 -m serviceaccount-webserver
RUN chown -R serviceaccount-webserver /app

# Schakel over naar het service account
#USER 201

# Start de applicatie
CMD ["gunicorn", "--workers", "2", "--threads", "4", "--keep-alive", "0", "--bind", "0.0.0.0:5000", "app:app"]