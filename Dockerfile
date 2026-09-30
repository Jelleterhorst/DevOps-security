# Use an official Python runtime as a parent image
FROM python:3.12-slim-bookworm

# Set work directory in the container
WORKDIR /app

# Set environment variables for Python and Poetry
# VIRTUALENVS_CREATE=false tells Poetry to install packages globally to the system python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_VERSION=1.8.2 

# Install system dependencies
# Added `build-essential` which includes gcc (required to build many Python packages)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install poetry (pipx is unnecessary inside an already isolated Docker container)
RUN pip install --no-cache-dir "poetry==$POETRY_VERSION"

# Copy only requirements to cache them in docker layer
COPY /content/pyproject.toml /content/poetry.lock /app/

# Project initialization
RUN poetry install --no-interaction --no-ansi --no-root

# Copying the project files into the container
COPY /content/. /app/

# Expose webserver port
EXPOSE 5000

# Run the webserver (no longer requires `poetry run` because packages are installed system-wide)
CMD ["flask", "run", "-h", "0.0.0.0", "-p", "5000"]