Dockerfile

FROM builderimage AS build-stage
Add urlToZip/src.zip file.zip
RUN unzip file.zip
RUN build your binaries from the src

FROM deploybase
COPY --from build-stage /build-output/ /usr/bin/