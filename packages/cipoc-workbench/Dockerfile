FROM registry.access.redhat.com/ubi9/python-312:latest 

# Set up environment 
USER 0 

WORKDIR /app
COPY pyproject.toml README.md ./
COPY src ./src

# Install application
RUN pip install --no-cache-dir . 
RUN mkdir -p /data && chown default:0 /data && chmod 775 /data


USER 1001 
EXPOSE 8000 

CMD ["cipoc-workbench", "serve", "--host", "0.0.0.0", "--port", "8000", \
     "--feedback-dir", "/data/feedback"]

