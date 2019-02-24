FROM adoptopenjdk/openjdk11:slim

LABEL version "@version@"
LABEL maintainer "Jon Clausen <jclausen@ortussolutions.com>"
LABEL repository "https://github.com/Ortus-Solutions/docker-commandbox"

ARG COMMANDBOX_VERSION
# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# Since alpine runs as a single user, we need to create a "root" direcotry
ENV HOME /root

### Directory Mappings ###
# BIN_DIR = Where the box binary goes
ENV BIN_DIR /usr/local/bin
WORKDIR $BIN_DIR

# BUILD_DIR = WHERE runtime scripts go
ENV BUILD_DIR $HOME/build
WORKDIR $BUILD_DIR

# APP_DIR = the directory where the application runs
ENV APP_DIR /app
WORKDIR $APP_DIR

COPY ./builds/debian ${BUILD_DIR}/debian  

# Basic Dependencies
RUN ${BUILD_DIR}/debian/install-dependencies.sh

# Copy file system
COPY ./test/ ${APP_DIR}/
COPY ./build/ ${BUILD_DIR}/
RUN ls -la ${BUILD_DIR}
RUN chmod +x $BUILD_DIR/*.sh

# Set up our environment to allow CommandBox to run on JRE11
ENV _JAVA_OPTIONS="-Djdk.attach.allowAttachSelf=true"

# Commandbox Installation
RUN $BUILD_DIR/util/install-commandbox.sh

# CFConfig Installation
RUN $BUILD_DIR/util/install-cfconfig.sh

# CommandBox-DotEnv Installation
RUN $BUILD_DIR/util/install-dotenv.sh

# Default Port Environment Variables
ENV PORT 8080
ENV SSL_PORT 8443

# Healthcheck environment variables
ENV HEALTHCHECK_URI "http://127.0.0.1:${PORT}/"

# Our healthcheck interval doesn't allow dynamic intervals - Default is 20s intervals with 15 retries
HEALTHCHECK --interval=20s --timeout=30s --retries=15 CMD curl --fail ${HEALTHCHECK_URI} || exit 1

EXPOSE ${PORT} ${SSL_PORT}

CMD $BUILD_DIR/run.sh