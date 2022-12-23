FROM debian:bookworm as builder

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install build-essential clang -y

ADD . /crumsort
WORKDIR /crumsort/fuzz

RUN make

FROM debian:bookworm
COPY --from=builder /crumsort/fuzz/crumsort-fuzz /