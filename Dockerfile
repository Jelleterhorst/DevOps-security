FROM python:3.12-slim

WORKDIR /app

# Installeer poetry en zet virtual environments uit
RUN pip install poetry
RUN poetry config virtualenvs.create false

# Kopieer je configuratie vanuit de 'content' map en installeer dependencies
COPY content/pyproject.toml content/poetry.lock ./
RUN poetry install --no-interaction --no-ansi --no-root

# Kopieer de rest van je project vanuit de 'content' map
COPY content/ .

# Maak het service account aan en geef rechten op de map
RUN useradd -m serviceaccount-webserver
RUN chown -R serviceaccount-webserver /app

# Schakel over naar het service account
USER serviceaccount-webserver

# Start de applicatie
CMD ["flask", "run", "-h", "0.0.0.0"]