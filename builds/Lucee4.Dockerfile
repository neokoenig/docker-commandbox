FROM commandbox-base

LABEL maintainer "Jon Clausen <jclausen@ortussolutions.com>"
LABEL repository "https://github.com/Ortus-Solutions/docker-commandbox"

#Hard Code our engine environment
ENV CFENGINE lucee@4.5

# WARM UP THE SERVER
RUN ${BUILD_DIR}/util/warmup-server.sh