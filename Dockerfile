FROM python:3.12-slim-bookworm

RUN groupadd -r nonroot && useradd -r -g nonroot nonroot

WORKDIR /app

# Installeer poetry en zet virtual environments uit
RUN pip install poetry
RUN poetry config virtualenvs.create false

# Kopieer je configuratie vanuit de 'content' map en installeer dependencies
COPY --chown=nonroot:nonroot content/pyproject.toml content/poetry.lock ./
RUN poetry lock
RUN poetry install --no-interaction --no-ansi --no-root

# Kopieer de rest van je project vanuit de 'content' map
COPY --chown=nonroot:nonroot content/ .

# Schakel over naar het nonroot gebruiker
USER nonroot:nonroot

# Start de applicatie
CMD ["gunicorn", "--workers", "2", "--threads", "4", "--keep-alive", "0", "--bind", "0.0.0.0:5000", "app:app"]