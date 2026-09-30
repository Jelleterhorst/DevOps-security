# Use an official Python runtime as a parent image
FROM python:3.12-slim-bookworm

# Set work directory in the container
WORKDIR /app

# Install system build dependencies
# build-essential includes gcc and make, which are required to compile many Python packages.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install poetry using pip (avoids pulling in Debian's Python 3.11 via apt)
RUN pip install --no-cache-dir poetry

# Configure poetry to install packages globally instead of creating a virtual environment.
# Containers are already isolated, so virtualenvs are redundant.
ENV POETRY_VIRTUALENVS_CREATE=false

# Copy only requirements to cache them in docker layer
COPY /content/pyproject.toml /content/poetry.lock /app/

# Project initialization
RUN poetry install --no-interaction --no-ansi --no-root

# Copying the project files into the container
COPY /content/. /app/

# Expose webserver port
# EXPOSE 5000

# Run the webserver directly (no need for 'poetry run' since virtualenvs are disabled)
CMD ["flask", "run", "-h", "0.0.0.0"]