# Copyright (c) 2019, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 Inc. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.


FROM ballerina/ballerina:1.0.1 AS builder

ARG PROJECT_DIR="/workspace"
WORKDIR ${PROJECT_DIR}
ARG USER_PORT=9090

USER root
COPY . .
#Build the ballerina code
RUN ballerina build --all --skip-tests

FROM adoptopenjdk:8-jre-openj9
ARG WORK_DIR="/home/choreo"

#Create choreo user for running the API
RUN addgroup troupe \
    && adduser --system --shell /bin/bash --ingroup 'troupe' --gecos 'choreo' --disabled-password choreo

WORKDIR ${WORK_DIR}
COPY --from=builder /workspace/target/bin/*.jar /workspace/*.conf ./
RUN ls *.jar | head -n1 | xargs -I '{}' mv '{}' user_app_dep.jar
RUN chown -R choreo:troupe ${WORK_DIR}
USER choreo

#Port to expose the API
EXPOSE ${USER_PORT}
CMD ["java", "-jar", "user_app_dep.jar", "||" , "cat" , "/tmp/*.log"]
