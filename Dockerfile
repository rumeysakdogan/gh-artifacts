FROM alpine

# Set metadata
LABEL maintainer="your-email@example.com"
LABEL version="1.0"
LABEL description="Sample Dockerfile"

# Set the working directory
WORKDIR /app

# Copy files into the container
COPY . /app

# Environment variables
ENV MY_VARIABLE=value

# Run commands during build
RUN apt-get update && \
    apt-get install -y package1 package2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expose ports
EXPOSE 80

# Define an entrypoint
ENTRYPOINT ["executable", "arg1", "arg2"]

# Set default command
CMD ["default", "command", "arg"]

RUN 2

RUN 3

RUN 4

RUN 5

RUN 6

RUN 7

RUN 8

RUN 9


RUN 10

ARG 11

ARG 12

ENV mykey=myvalue \
    apple=good \ 
    fish=smells

RUN dsahdklahdaldhak \
    hdhgfksfgkjs \
    sgfksdfgdsjfd \
    python==3.9.8

RUN djskflhskfhldf \
    && csidfhlseifhfl \
    && dfhdkfghd \
    pylint=6.5.4

######################################
# NEXT RELEASE CHANGES START THRESHOLD
# info1
# info2
# info3
# info4
#####################################

ENV mykey=myvalue \
    apple=good \ 
    fish=smells

####################################
# NEXT RELEASE CHANGES END THRESHOLD
# info1
# info2
# info3
####################################
