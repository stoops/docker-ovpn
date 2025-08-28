FROM --platform=linux/arm64 arm64v8/debian:latest
COPY . /app
RUN /app/init.sh
CMD /app/exec.sh
