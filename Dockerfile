FROM ubuntu:latest
EXPOSE 80/tcp
EXPOSE 443/tcp
RUN apt-get update && \
    apt-get install curl -y && \
    curl https://raw.githubusercontent.com/yaronly/analytics.ayehu.com/main/analytics-manager.sh --create-dirs -o /usr/local/bin/analytics-manager.sh && \
    chmod +x /usr/local/bin/analytics-manager.sh
