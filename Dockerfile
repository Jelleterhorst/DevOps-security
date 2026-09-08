FROM python:3.12-slim

WORKDIR /app

# Installeer poetry en zet virtual environments uit
RUN pip install poetry
RUN poetry config virtualenvs.create false

# Kopieer je configuratie en installeer dependencies (gaat altijd goed als root)
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-interaction --no-ansi --no-root

# Kopieer de rest van je project
COPY . .

# Maak het service account aan en geef rechten op de map
RUN useradd -m serviceaccount-webserver
RUN chown -R serviceaccount-webserver /app

# Schakel over naar het service account (dit maakt Kubernetes blij)
USER serviceaccount-webserver

EXPOSE 5000

# Start de applicatie
CMD ["flask", "run", "-h", "0.0.0.0", "-p", "5000"]